import jwt from "jsonwebtoken";
import { prisma } from "../../db/prisma";
import { loadEnv } from "../../config/env";
import { AppError } from "../../middleware/error.middleware";
import { randomOtp, randomToken, safeCompare, sha256 } from "../../utils/crypto";
import { logger } from "../../utils/logger";
import type { SendOtpInput, VerifyOtpInput, RefreshInput } from "./auth.schema";
import { sendOtpSms } from "./sms.client";

const accessTokenTtlSeconds = 60 * 60;
const refreshTokenTtlDays = 30;
const otpTtlSeconds = 5 * 60;
const resendAfterSeconds = 30;
const maxOtpAttempts = 5;

function addSeconds(date: Date, seconds: number): Date {
  return new Date(date.getTime() + seconds * 1000);
}

function addDays(date: Date, days: number): Date {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}

function hashOtp(phone: string, otp: string): string {
  return sha256(`${loadEnv().OTP_HASH_SECRET}:${phone}:${otp}`);
}

function hashRefreshToken(refreshToken: string): string {
  return sha256(`${loadEnv().JWT_REFRESH_SECRET}:${refreshToken}`);
}

function signAccessToken(input: {
  userId: string;
  sessionId: string;
  kycStatus: string;
}): string {
  return jwt.sign(
    {
      user_id: input.userId,
      session_id: input.sessionId,
      kyc_status: input.kycStatus,
    },
    loadEnv().JWT_SECRET,
    { expiresIn: accessTokenTtlSeconds },
  );
}

const MOCK_SMS_OTP = "123456";

function generateOtp(): string {
  const env = loadEnv();

  // Jest/integration tests may override the code without touching live providers.
  if (process.env.NODE_ENV === "test") {
    return process.env.TEST_OTP_CODE ?? MOCK_SMS_OTP;
  }

  // Staging / dev: fixed OTP only when SMS is explicitly in mock mode.
  if (env.SMS_PROVIDER_MODE === "mock") {
    // Defense in depth — loadEnv blocks production+mock, but never emit 123456
    // if this server is labelled production.
    if (env.NODE_ENV === "production") {
      logger.error("Refusing fixed mock OTP in production", { provider: "mock" });
      return randomOtp();
    }
    return MOCK_SMS_OTP;
  }

  return randomOtp();
}

function toUserSummary(user: {
  id: string;
  phone: string;
  name: string | null;
  kycStatus: string;
  createdAt: Date;
}) {
  return {
    id: user.id,
    phone: user.phone,
    name: user.name,
    kyc_status: user.kycStatus,
    is_new_user: user.name === null,
  };
}

export class AuthService {
  async sendOtp(input: SendOtpInput) {
    const otp = generateOtp();
    const now = new Date();

    const existingUser = await prisma.user.findUnique({
      where: { phone: input.phone },
      select: { id: true },
    });

    const otpSession = await prisma.otpSession.create({
      data: {
        phone: input.phone,
        userId: existingUser?.id,
        otpHash: hashOtp(input.phone, otp),
        expiresAt: addSeconds(now, otpTtlSeconds),
      },
      select: {
        id: true,
      },
    });

    try {
      await sendOtpSms({ phone: input.phone, otp });
    } catch (err) {
      logger.error("OTP SMS dispatch failed", {
        phone: input.phone.slice(0, 4) + "****",
        error: err instanceof Error ? err.message : String(err),
      });

      await prisma.otpSession.delete({ where: { id: otpSession.id } });

      throw new AppError(
        503,
        "PROVIDER_UNAVAILABLE",
        "Could not send verification code. Please try again.",
      );
    }

    return {
      otp_session_id: otpSession.id,
      expires_in_seconds: otpTtlSeconds,
      resend_allowed_after_seconds: resendAfterSeconds,
    };
  }

  async verifyOtp(input: VerifyOtpInput) {
    const now = new Date();
    const otpSession = await prisma.otpSession.findUnique({
      where: { id: input.otp_session_id },
    });

    if (!otpSession || otpSession.status !== "pending") {
      throw new AppError(401, "UNAUTHORIZED", "Invalid OTP session");
    }

    if (otpSession.expiresAt <= now) {
      await prisma.otpSession.update({
        where: { id: otpSession.id },
        data: { status: "expired" },
      });
      throw new AppError(401, "UNAUTHORIZED", "OTP has expired");
    }

    // Re-read attempt count inside a transaction so concurrent requests don't
    // both see stale values and both slip past the brute-force guard.
    const candidateHash = hashOtp(otpSession.phone, input.otp);
    const isCorrect = safeCompare(candidateHash, otpSession.otpHash);

    if (!isCorrect) {
      const updated = await prisma.otpSession.update({
        where: {
          id: otpSession.id,
          status: "pending",
        },
        data: { attempts: { increment: 1 } },
        select: { attempts: true },
      });

      if (updated.attempts >= maxOtpAttempts) {
        await prisma.otpSession.update({
          where: { id: otpSession.id },
          data: { status: "blocked", blockedAt: now },
        });
        throw new AppError(429, "RATE_LIMITED", "OTP session is blocked");
      }

      throw new AppError(401, "UNAUTHORIZED", "Incorrect OTP");
    }

    if (otpSession.attempts >= maxOtpAttempts) {
      await prisma.otpSession.update({
        where: { id: otpSession.id },
        data: { status: "blocked", blockedAt: now },
      });
      throw new AppError(429, "RATE_LIMITED", "OTP session is blocked");
    }

    const result = await prisma.$transaction(async (tx) => {
      const user = await tx.user.upsert({
        where: { phone: otpSession.phone },
        update: {
          lastActiveAt: now,
        },
        create: {
          phone: otpSession.phone,
          lastActiveAt: now,
        },
        select: {
          id: true,
          phone: true,
          name: true,
          kycStatus: true,
          createdAt: true,
        },
      });

      await tx.otpSession.update({
        where: { id: otpSession.id },
        data: {
          userId: user.id,
          status: "verified",
          verifiedAt: now,
        },
      });

      const refreshToken = randomToken();
      const session = await tx.authSession.create({
        data: {
          userId: user.id,
          refreshTokenHash: hashRefreshToken(refreshToken),
          expiresAt: addDays(now, refreshTokenTtlDays),
          lastUsedAt: now,
        },
        select: {
          id: true,
        },
      });

      return { user, session, refreshToken };
    });

    return {
      access_token: signAccessToken({
        userId: result.user.id,
        sessionId: result.session.id,
        kycStatus: result.user.kycStatus,
      }),
      refresh_token: result.refreshToken,
      expires_in: accessTokenTtlSeconds,
      user: toUserSummary(result.user),
    };
  }

  async refresh(input: RefreshInput) {
    const refreshTokenHash = hashRefreshToken(input.refresh_token);
    const session = await prisma.authSession.findUnique({
      where: { refreshTokenHash },
      select: {
        id: true,
        expiresAt: true,
        revokedAt: true,
        user: {
          select: {
            id: true,
            kycStatus: true,
            deletedAt: true,
          },
        },
      },
    });

    if (
      !session ||
      session.revokedAt ||
      session.expiresAt <= new Date() ||
      session.user.deletedAt
    ) {
      throw new AppError(401, "UNAUTHORIZED", "Invalid refresh token");
    }

    await prisma.authSession.update({
      where: { id: session.id },
      data: { lastUsedAt: new Date() },
    });

    return {
      access_token: signAccessToken({
        userId: session.user.id,
        sessionId: session.id,
        kycStatus: session.user.kycStatus,
      }),
      expires_in: accessTokenTtlSeconds,
    };
  }

  async logout(sessionId: string) {
    await prisma.authSession.update({
      where: { id: sessionId },
      data: { revokedAt: new Date() },
    });

    return { success: true };
  }
}

export const authService = new AuthService();
