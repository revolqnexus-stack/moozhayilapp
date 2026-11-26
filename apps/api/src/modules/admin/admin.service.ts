import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import { writeAuditLog } from "../../utils/audit";
import { openKycSelfieStream } from "../../utils/kyc_storage";
import { kycService } from "../kyc/kyc.service";
import { notifyKycRejected, notifyKycVerified } from "../notifications/notifications.triggers";
import type { RejectKycInput } from "./admin.schema";

export class AdminService {
  async listKycReviews() {
    const pending = await prisma.user.findMany({
      where: { kycStatus: "in_review" },
      select: {
        id: true,
        name: true,
        phone: true,
        kycStatus: true,
        kycDocument: {
          select: {
            submittedAt: true,
            aadhaarVerified: true,
            panVerified: true,
            selfieVerified: true,
            selfieS3Key: true,
          },
        },
      },
      orderBy: { updatedAt: "asc" },
    });

    const verified = await prisma.user.findMany({
      where: {
        kycStatus: { in: ["basic_verified", "enhanced_verified"] },
        deletedAt: null,
      },
      select: {
        id: true,
        name: true,
        phone: true,
        kycStatus: true,
        kycVerifiedAt: true,
        kycDocument: { select: { panVerified: true, aadhaarVerified: true } },
      },
      orderBy: { kycVerifiedAt: { sort: "desc", nulls: "last" } },
      take: 200,
    });

    return {
      verified: verified.map((user) => ({
        user_id: user.id,
        name: user.name,
        phone: user.phone,
        kyc_status: user.kycStatus,
        verified_at: user.kycVerifiedAt?.toISOString() ?? null,
        pan_verified: user.kycDocument?.panVerified ?? false,
        aadhaar_verified: user.kycDocument?.aadhaarVerified ?? false,
      })),
      reviews: pending.map((user) => ({
        user_id: user.id,
        name: user.name,
        phone: user.phone,
        kyc_status: user.kycStatus,
        submitted_at: user.kycDocument?.submittedAt?.toISOString() ?? null,
        aadhaar_verified: user.kycDocument?.aadhaarVerified ?? false,
        pan_verified: user.kycDocument?.panVerified ?? false,
        selfie_verified: user.kycDocument?.selfieVerified ?? false,
        selfie_preview_available: Boolean(user.kycDocument?.selfieS3Key),
      })),
    };
  }

  async getKycSelfieStream(userId: string): Promise<{
    stream: NodeJS.ReadableStream;
    contentType: string;
  }> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        kycDocument: {
          select: { selfieS3Key: true },
        },
      },
    });

    const selfieKey = user?.kycDocument?.selfieS3Key;
    if (!selfieKey) {
      throw new AppError(404, "NOT_FOUND", "Selfie not available");
    }

    const stream = await openKycSelfieStream(selfieKey);
    if (!stream) {
      throw new AppError(404, "NOT_FOUND", "Selfie file not found");
    }

    return {
      stream,
      contentType: selfieKey.endsWith(".png") ? "image/png" : "image/jpeg",
    };
  }

  async approveKyc(
    userId: string,
    adminId: string,
    requestId?: string,
    ipAddress?: string,
  ) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { kycDocument: true },
    });

    if (!user?.kycDocument) {
      throw new AppError(404, "NOT_FOUND", "KYC submission does not exist");
    }

    if (user.kycStatus !== "in_review") {
      throw new AppError(409, "CONFLICT", "KYC is not pending review");
    }

    const nextStatus = kycService.resolveVerifiedTier(user.kycDocument);
    const now = new Date();
    const before = { kyc_status: user.kycStatus };

    await prisma.$transaction(async (tx) => {
      await tx.user.update({
        where: { id: userId },
        data: {
          kycStatus: nextStatus,
          kycVerifiedAt: now,
        },
      });

      await tx.kycDocument.update({
        where: { userId },
        data: {
          reviewedAt: now,
          reviewerId: adminId,
          rejectionReason: null,
        },
      });
    });

    await writeAuditLog({
      actorType: "admin",
      actorId: adminId,
      action: "kyc_approved",
      entityType: "user",
      entityId: userId,
      before,
      after: { kyc_status: nextStatus },
      requestId,
      ipAddress,
    });

    await notifyKycVerified({ userId });

    return {
      success: true,
      kyc_status: nextStatus,
    };
  }

  async rejectKyc(
    userId: string,
    adminId: string,
    input: RejectKycInput,
    requestId?: string,
    ipAddress?: string,
  ) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { kycStatus: true },
    });

    if (!user) {
      throw new AppError(404, "NOT_FOUND", "User does not exist");
    }

    if (user.kycStatus !== "in_review") {
      throw new AppError(409, "CONFLICT", "KYC is not pending review");
    }

    const now = new Date();
    const before = { kyc_status: user.kycStatus };

    await prisma.$transaction(async (tx) => {
      await tx.user.update({
        where: { id: userId },
        data: { kycStatus: "rejected" },
      });

      await tx.kycDocument.update({
        where: { userId },
        data: {
          reviewedAt: now,
          reviewerId: adminId,
          rejectionReason: input.reason,
        },
      });
    });

    await writeAuditLog({
      actorType: "admin",
      actorId: adminId,
      action: "kyc_rejected",
      entityType: "user",
      entityId: userId,
      before,
      after: { kyc_status: "rejected" },
      reason: input.reason,
      requestId,
      ipAddress,
    });

    await notifyKycRejected({ userId, reason: input.reason });

    return {
      success: true,
      kyc_status: "rejected" as const,
    };
  }
}

export const adminService = new AdminService();
