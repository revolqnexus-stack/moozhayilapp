import type { KycStatus } from "@prisma/client";
import { prisma } from "../../db/prisma";
import { loadEnv } from "../../config/env";
import {
  KYC_AADHAAR_OTP_TTL_SECONDS,
  KYC_ESTIMATED_REVIEW_MINUTES,
  KYC_MAX_AADHAAR_OTP_ATTEMPTS,
  KYC_MAX_REJECTIONS_BEFORE_ESCALATION,
  KYC_RESUBMISSION_COOLDOWN_HOURS,
  KYC_SELFIE_MAX_BYTES,
} from "../../config/kyc.constants";
import { AppError } from "../../middleware/error.middleware";
import { writeAuditLog } from "../../utils/audit";
import {
  decryptSensitive,
  encryptSensitive,
  randomOtp,
  safeCompare,
  sha256,
} from "../../utils/crypto";
import { storeKycSelfie } from "../../utils/kyc_storage";
import { namesMatch } from "../../utils/name_match";
import { maskName } from "../../utils/pii";
import type {
  SendAadhaarOtpInput,
  VerifyAadhaarOtpInput,
  VerifyBankAccountInput,
  VerifyPanInput,
} from "./kyc.schema";
import {
  isBankNameMatchResultOk,
  maskBankAccountNumber,
} from "./bank_account.util";
import { mapStampMitraErrorToAppError } from "./stampmitra.errors";
import {
  verifyBankAccountWithStampMitra,
  type StampMitraBankAccountVerifyResponse,
} from "./stampmitra.client";
import { kycProviderClient } from "./kyc_provider.client";

function piiSecret(): string {
  return loadEnv().PII_ENCRYPTION_SECRET;
}

function hashKycOtp(userId: string, otp: string): string {
  return sha256(`${loadEnv().OTP_HASH_SECRET}:kyc:${userId}:${otp}`);
}

function generateKycOtp(): string {
  if (process.env.NODE_ENV === "test") {
    return process.env.TEST_KYC_AADHAAR_OTP ?? "654321";
  }

  return randomOtp();
}

function addHours(date: Date, hours: number): Date {
  return new Date(date.getTime() + hours * 60 * 60 * 1000);
}

function addSeconds(date: Date, seconds: number): Date {
  return new Date(date.getTime() + seconds * 1000);
}

async function ensureKycDocument(userId: string) {
  return prisma.kycDocument.upsert({
    where: { userId },
    create: { userId },
    update: {},
  });
}

async function countRejections(userId: string): Promise<number> {
  return prisma.auditLog.count({
    where: {
      entityType: "user",
      entityId: userId,
      action: "kyc_rejected",
    },
  });
}

function computeResubmissionAllowedAt(
  kycStatus: KycStatus,
  reviewedAt: Date | null,
): string | null {
  if (kycStatus !== "rejected" || !reviewedAt) {
    return null;
  }

  const allowedAt = addHours(reviewedAt, KYC_RESUBMISSION_COOLDOWN_HOURS);
  if (allowedAt <= new Date()) {
    return null;
  }

  return allowedAt.toISOString();
}

async function assertCanStartKyc(userId: string): Promise<void> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { kycStatus: true, kycDocument: { select: { reviewedAt: true } } },
  });

  if (!user) {
    throw new AppError(404, "NOT_FOUND", "User does not exist");
  }

  if (user.kycStatus === "in_review") {
    throw new AppError(409, "CONFLICT", "KYC submission is already in review");
  }

  if (user.kycStatus === "basic_verified" || user.kycStatus === "enhanced_verified") {
    throw new AppError(409, "CONFLICT", "KYC is already verified");
  }

  if (user.kycStatus === "rejected") {
    const allowedAt = computeResubmissionAllowedAt(
      user.kycStatus,
      user.kycDocument?.reviewedAt ?? null,
    );
    if (allowedAt) {
      throw new AppError(403, "FORBIDDEN", "KYC resubmission is on cooldown", {
        resubmission_allowed_at: allowedAt,
      });
    }

    const rejections = await countRejections(userId);
    if (rejections >= KYC_MAX_REJECTIONS_BEFORE_ESCALATION) {
      throw new AppError(
        403,
        "FORBIDDEN",
        "Multiple KYC rejections require manual support review",
      );
    }
  }
}

async function markInProgress(userId: string): Promise<void> {
  await prisma.user.updateMany({
    where: {
      id: userId,
      kycStatus: { in: ["not_started", "rejected"] },
    },
    data: { kycStatus: "in_progress" },
  });
}

export class KycService {
  async getStatus(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { kycDocument: true },
    });

    if (!user || user.deletedAt) {
      throw new AppError(404, "NOT_FOUND", "User does not exist");
    }

    const doc = user.kycDocument;

    return {
      kyc_status: user.kycStatus,
      aadhaar_verified: doc?.aadhaarVerified ?? false,
      pan_verified: doc?.panVerified ?? false,
      bank_verified: doc?.bankVerified ?? false,
      selfie_verified: doc?.selfieVerified ?? false,
      submitted_at: doc?.submittedAt?.toISOString() ?? null,
      rejection_reason: doc?.rejectionReason ?? null,
      resubmission_allowed_at: computeResubmissionAllowedAt(
        user.kycStatus,
        doc?.reviewedAt ?? null,
      ),
    };
  }

  async sendAadhaarOtp(userId: string, input: SendAadhaarOtpInput) {
    await assertCanStartKyc(userId);
    await markInProgress(userId);

    const providerResult = await kycProviderClient.sendAadhaarOtp(
      input.aadhaar_number,
    );
    const env = loadEnv();
    const now = new Date();
    const otp = generateKycOtp();

    const otpHash =
      env.KYC_PROVIDER_MODE === "mock"
        ? hashKycOtp(userId, otp)
        : sha256(`live:${providerResult.providerSessionId}`);

    const session = await prisma.kycAadhaarSession.create({
      data: {
        userId,
        aadhaarNumberEncrypted: encryptSensitive(
          input.aadhaar_number,
          piiSecret(),
        ),
        otpHash,
        expiresAt: addSeconds(now, KYC_AADHAAR_OTP_TTL_SECONDS),
      },
      select: { id: true },
    });

    return {
      session_id: session.id,
      expires_in_seconds: KYC_AADHAAR_OTP_TTL_SECONDS,
    };
  }

  async verifyAadhaarOtp(userId: string, input: VerifyAadhaarOtpInput) {
    const session = await prisma.kycAadhaarSession.findFirst({
      where: {
        id: input.session_id,
        userId,
        verifiedAt: null,
      },
    });

    if (!session || session.expiresAt <= new Date()) {
      throw new AppError(400, "BAD_REQUEST", "Aadhaar OTP session is invalid or expired");
    }

    if (session.attempts >= KYC_MAX_AADHAAR_OTP_ATTEMPTS) {
      throw new AppError(429, "RATE_LIMITED", "Too many Aadhaar OTP attempts");
    }

    const aadhaarNumber = decryptSensitive(
      session.aadhaarNumberEncrypted,
      piiSecret(),
    );
    const providerResult = await kycProviderClient.verifyAadhaarOtp(
      aadhaarNumber,
      input.otp,
    );

    const env = loadEnv();
    const verified =
      env.KYC_PROVIDER_MODE === "mock"
        ? providerResult.verified &&
          safeCompare(session.otpHash, hashKycOtp(userId, input.otp))
        : providerResult.verified;

    if (!verified) {
      await prisma.kycAadhaarSession.update({
        where: { id: session.id },
        data: { attempts: { increment: 1 } },
      });
      throw new AppError(400, "BAD_REQUEST", "Invalid Aadhaar OTP");
    }

    await prisma.$transaction(async (tx) => {
      await tx.kycAadhaarSession.update({
        where: { id: session.id },
        data: { verifiedAt: new Date() },
      });

      await tx.kycDocument.upsert({
        where: { userId },
        create: {
          userId,
          aadhaarNumberEncrypted: session.aadhaarNumberEncrypted,
          aadhaarVerified: true,
          nameOnAadhaarEncrypted: encryptSensitive(
            providerResult.nameOnAadhaar,
            piiSecret(),
          ),
        },
        update: {
          aadhaarNumberEncrypted: session.aadhaarNumberEncrypted,
          aadhaarVerified: true,
          nameOnAadhaarEncrypted: encryptSensitive(
            providerResult.nameOnAadhaar,
            piiSecret(),
          ),
        },
      });
    });

    return {
      verified: true,
      name_on_aadhaar_masked: maskName(providerResult.nameOnAadhaar),
    };
  }

  async verifyPan(userId: string, input: VerifyPanInput) {
    await assertCanStartKyc(userId);
    await markInProgress(userId);

    const providerResult = await kycProviderClient.verifyPan(
      input.pan_number,
      input.name,
    );
    const now = new Date();
    const panIsValid = providerResult.panStatus.toUpperCase() === "VALID";
    const nameMismatch =
      input.name &&
      providerResult.nameMatchResult &&
      providerResult.nameMatchResult.toUpperCase() !== "MATCH";

    await writeAuditLog({
      actorType: "user",
      actorId: userId,
      action: "kyc_pan_verification",
      entityType: "user",
      entityId: userId,
      after: {
        reference_id: providerResult.referenceId,
        valid: providerResult.verified,
        pan_status: providerResult.panStatus,
        name_match_result: providerResult.nameMatchResult,
      },
    });

    const auditFields = {
      panVerificationReferenceId: providerResult.referenceId,
      panVerificationValid: providerResult.verified,
      panVerifiedAt: now,
      panVerified: false,
    };

    if (!panIsValid) {
      await prisma.kycDocument.upsert({
        where: { userId },
        create: { userId, ...auditFields },
        update: auditFields,
      });

      return {
        verified: false,
        reference_id: providerResult.referenceId,
        pan_status: providerResult.panStatus,
        name_match_result: providerResult.nameMatchResult,
        message: providerResult.message || "PAN not valid",
      };
    }

    if (nameMismatch || !providerResult.verified) {
      await prisma.kycDocument.upsert({
        where: { userId },
        create: { userId, ...auditFields },
        update: auditFields,
      });

      return {
        verified: false,
        reference_id: providerResult.referenceId,
        pan_status: providerResult.panStatus,
        name_match_result: providerResult.nameMatchResult,
        name_on_pan_masked: providerResult.nameOnPan
          ? maskName(providerResult.nameOnPan)
          : null,
        message: "Name does not match PAN records",
      };
    }

    await prisma.kycDocument.upsert({
      where: { userId },
      create: {
        userId,
        panNumberEncrypted: encryptSensitive(input.pan_number, piiSecret()),
        nameOnPanEncrypted: encryptSensitive(
          providerResult.nameOnPan,
          piiSecret(),
        ),
        panVerificationReferenceId: providerResult.referenceId,
        panVerificationValid: true,
        panVerifiedAt: now,
        panVerified: true,
      },
      update: {
        panNumberEncrypted: encryptSensitive(input.pan_number, piiSecret()),
        nameOnPanEncrypted: encryptSensitive(
          providerResult.nameOnPan,
          piiSecret(),
        ),
        panVerificationReferenceId: providerResult.referenceId,
        panVerificationValid: true,
        panVerifiedAt: now,
        panVerified: true,
      },
    });

    return {
      verified: true,
      reference_id: providerResult.referenceId,
      pan_status: providerResult.panStatus,
      name_match_result: providerResult.nameMatchResult,
      name_on_pan_masked: maskName(providerResult.nameOnPan),
      pan_type: providerResult.panType,
      message: providerResult.message,
    };
  }

  async verifyBankAccount(userId: string, input: VerifyBankAccountInput) {
    await assertCanStartKyc(userId);
    await markInProgress(userId);

    const env = loadEnv();
    let providerResult: StampMitraBankAccountVerifyResponse;

    if (env.KYC_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production" && !env.MOOZHAYIL_ALLOW_MOCK_KYC) {
        throw new AppError(503, "PROVIDER_UNAVAILABLE", "Mock KYC disabled in production");
      }

      const mockName = "MOCK BANK USER";
      const nameMatchResult =
        input.name && input.name.trim().toUpperCase() !== mockName
          ? "NO_MATCH"
          : "GOOD_MATCH";

      providerResult = {
        referenceId: `mock_bank_${input.account_number.slice(-4)}`,
        valid: true,
        nameAtBank: mockName,
        bankName: "Mock Bank",
        utr: "",
        city: "Thrissur",
        branch: "Main",
        micr: "",
        nameMatchScore: nameMatchResult === "GOOD_MATCH" ? "100" : "20",
        nameMatchResult,
        accountStatus: "ACCOUNT_IS_VALID",
        accountStatusCode: "1",
      };
    } else {
      try {
        providerResult = await verifyBankAccountWithStampMitra({
          accountNumber: input.account_number,
          ifsc: input.ifsc,
          name: input.name,
        });
      } catch (error) {
        throw mapStampMitraErrorToAppError(error, {
          operation: "verify_bank_account",
          requiredScope: "verification.bank-account.read",
        });
      }
    }

    const now = new Date();
    const nameProvided = Boolean(input.name);
    const nameMatchOk = isBankNameMatchResultOk(
      providerResult.nameMatchResult,
      nameProvided,
    );
    const verified =
      providerResult.valid && nameMatchOk && providerResult.accountStatus !== "";

    await writeAuditLog({
      actorType: "user",
      actorId: userId,
      action: "kyc_bank_verification",
      entityType: "user",
      entityId: userId,
      after: {
        reference_id: providerResult.referenceId,
        valid: verified,
        account_status: providerResult.accountStatus,
        name_match_result: providerResult.nameMatchResult,
        account_masked: maskBankAccountNumber(input.account_number),
      },
    });

    const auditFields = {
      bankVerificationReferenceId: providerResult.referenceId,
      bankVerificationValid: verified,
      bankVerifiedAt: now,
      bankVerified: false,
    };

    if (!providerResult.valid) {
      await prisma.kycDocument.upsert({
        where: { userId },
        create: { userId, ...auditFields },
        update: auditFields,
      });

      return {
        verified: false,
        reference_id: providerResult.referenceId,
        account_status: providerResult.accountStatus,
        name_match_result: providerResult.nameMatchResult,
        message: "Bank account could not be verified",
      };
    }

    if (!nameMatchOk) {
      await prisma.kycDocument.upsert({
        where: { userId },
        create: { userId, ...auditFields },
        update: auditFields,
      });

      return {
        verified: false,
        reference_id: providerResult.referenceId,
        account_status: providerResult.accountStatus,
        name_match_result: providerResult.nameMatchResult,
        name_at_bank_masked: providerResult.nameAtBank
          ? maskName(providerResult.nameAtBank)
          : null,
        bank_name: providerResult.bankName,
        message: "Name does not match bank records",
      };
    }

    await prisma.kycDocument.upsert({
      where: { userId },
      create: {
        userId,
        bankAccountNumberEncrypted: encryptSensitive(
          input.account_number,
          piiSecret(),
        ),
        bankIfscEncrypted: encryptSensitive(input.ifsc, piiSecret()),
        nameAtBankEncrypted: providerResult.nameAtBank
          ? encryptSensitive(providerResult.nameAtBank, piiSecret())
          : null,
        bankVerificationReferenceId: providerResult.referenceId,
        bankVerificationValid: true,
        bankVerifiedAt: now,
        bankVerified: true,
      },
      update: {
        bankAccountNumberEncrypted: encryptSensitive(
          input.account_number,
          piiSecret(),
        ),
        bankIfscEncrypted: encryptSensitive(input.ifsc, piiSecret()),
        nameAtBankEncrypted: providerResult.nameAtBank
          ? encryptSensitive(providerResult.nameAtBank, piiSecret())
          : null,
        bankVerificationReferenceId: providerResult.referenceId,
        bankVerificationValid: true,
        bankVerifiedAt: now,
        bankVerified: true,
      },
    });

    return {
      verified: true,
      reference_id: providerResult.referenceId,
      account_status: providerResult.accountStatus,
      name_match_result: providerResult.nameMatchResult,
      name_at_bank_masked: providerResult.nameAtBank
        ? maskName(providerResult.nameAtBank)
        : null,
      bank_name: providerResult.bankName,
      branch: providerResult.branch,
      account_masked: maskBankAccountNumber(input.account_number),
    };
  }

  async uploadSelfie(
    userId: string,
    file: { buffer: Buffer; mimetype: string; size: number },
  ) {
    await assertCanStartKyc(userId);
    await markInProgress(userId);

    if (!["image/jpeg", "image/png"].includes(file.mimetype)) {
      throw new AppError(422, "UNPROCESSABLE", "Selfie must be JPEG or PNG");
    }

    if (file.size > KYC_SELFIE_MAX_BYTES) {
      throw new AppError(422, "UNPROCESSABLE", "Selfie exceeds 5MB limit");
    }

    const verification = await kycProviderClient.verifySelfie(
      file.buffer,
      file.mimetype,
    );
    if (!verification.faceDetected) {
      throw new AppError(
        422,
        "UNPROCESSABLE",
        "No face detected in selfie image",
      );
    }

    const stored = await storeKycSelfie(userId, file.buffer, file.mimetype);

    await prisma.kycDocument.upsert({
      where: { userId },
      create: {
        userId,
        selfieS3Key: stored.s3Key,
        selfieVerified: true,
      },
      update: {
        selfieS3Key: stored.s3Key,
        selfieVerified: true,
      },
    });

    return {
      uploaded: true,
      face_detected: true,
    };
  }

  async submit(userId: string) {
    const doc = await ensureKycDocument(userId);
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { kycStatus: true },
    });

    if (!user) {
      throw new AppError(404, "NOT_FOUND", "User does not exist");
    }

    if (user.kycStatus === "in_review") {
      throw new AppError(409, "CONFLICT", "KYC is already submitted for review");
    }

    if (!doc.selfieVerified) {
      throw new AppError(422, "UNPROCESSABLE", "Selfie verification is required");
    }

    if (!doc.aadhaarVerified && !doc.panVerified) {
      throw new AppError(
        422,
        "UNPROCESSABLE",
        "Aadhaar or PAN verification is required before submission",
      );
    }

    const now = new Date();

    await prisma.$transaction(async (tx) => {
      await tx.kycDocument.update({
        where: { userId },
        data: {
          submittedAt: now,
          rejectionReason: null,
          reviewedAt: null,
          reviewerId: null,
        },
      });

      await tx.user.update({
        where: { id: userId },
        data: { kycStatus: "in_review" },
      });
    });

    await writeAuditLog({
      actorType: "user",
      actorId: userId,
      action: "kyc_submitted",
      entityType: "user",
      entityId: userId,
      after: { kyc_status: "in_review" },
    });

    return {
      kyc_status: "in_review" as const,
      estimated_completion: `${KYC_ESTIMATED_REVIEW_MINUTES} minutes`,
    };
  }

  resolveVerifiedTier(doc: {
    aadhaarVerified: boolean;
    panVerified: boolean;
    selfieVerified: boolean;
    nameOnAadhaarEncrypted: string | null;
    nameOnPanEncrypted: string | null;
  }): KycStatus {
    if (!doc.selfieVerified) {
      throw new AppError(422, "UNPROCESSABLE", "Selfie verification is missing");
    }

    const hasAadhaar = doc.aadhaarVerified;
    const hasPan = doc.panVerified;

    if (hasAadhaar && hasPan) {
      const aadhaarName = doc.nameOnAadhaarEncrypted
        ? decryptSensitive(doc.nameOnAadhaarEncrypted, piiSecret())
        : "";
      const panName = doc.nameOnPanEncrypted
        ? decryptSensitive(doc.nameOnPanEncrypted, piiSecret())
        : "";

      if (!namesMatch(aadhaarName, panName)) {
        throw new AppError(
          422,
          "UNPROCESSABLE",
          "Names on Aadhaar and PAN do not match",
        );
      }

      return "enhanced_verified";
    }

    if ((hasAadhaar && doc.selfieVerified) || (hasPan && doc.selfieVerified)) {
      return "basic_verified";
    }

    throw new AppError(
      422,
      "UNPROCESSABLE",
      "Insufficient verified documents for approval",
    );
  }
}

export const kycService = new KycService();
