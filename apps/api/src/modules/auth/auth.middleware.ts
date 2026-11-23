import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import { loadEnv } from "../../config/env";
import { authenticatedUserRateLimit } from "../../middleware/rate_limit.middleware";

export interface AuthenticatedUser {
  userId: string;
  sessionId: string;
  kycStatus: string;
}

declare module "express-serve-static-core" {
  interface Request {
    user?: AuthenticatedUser;
  }
}

interface AccessTokenPayload {
  user_id: string;
  session_id: string;
  kyc_status: string;
}

function isAccessTokenPayload(value: unknown): value is AccessTokenPayload {
  if (!value || typeof value !== "object") {
    return false;
  }

  const payload = value as Record<string, unknown>;
  return (
    typeof payload.user_id === "string" &&
    typeof payload.session_id === "string" &&
    typeof payload.kyc_status === "string"
  );
}

export async function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const header = req.header("authorization");
    console.log('🔐 Auth middleware - Path:', req.path, 'Has auth header:', !!header);
    
    if (!header?.startsWith("Bearer ")) {
      console.log('🔐 Auth failed: Missing Bearer token');
      throw new AppError(401, "UNAUTHORIZED", "Missing access token");
    }

    const token = header.slice("Bearer ".length);
    const env = loadEnv();
    const decoded = jwt.verify(token, env.JWT_SECRET);

    if (!isAccessTokenPayload(decoded)) {
      console.log('🔐 Auth failed: Invalid token payload');
      throw new AppError(401, "UNAUTHORIZED", "Invalid access token");
    }

    console.log('🔐 Token decoded - user_id:', decoded.user_id, 'session_id:', decoded.session_id);

    const session = await prisma.authSession.findUnique({
      where: { id: decoded.session_id },
      select: {
        id: true,
        userId: true,
        expiresAt: true,
        revokedAt: true,
        user: {
          select: {
            deletedAt: true,
            kycStatus: true,
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
      console.log('🔐 Auth failed: Session invalid or expired', {
        exists: !!session,
        revoked: session?.revokedAt,
        expired: session ? session.expiresAt <= new Date() : null,
        userDeleted: session?.user.deletedAt,
      });
      throw new AppError(401, "UNAUTHORIZED", "Invalid access token");
    }

    req.user = {
      userId: session.userId,
      sessionId: session.id,
      kycStatus: session.user.kycStatus,
    };

    console.log('🔐 Auth success - user:', req.user.userId);
    authenticatedUserRateLimit(req, _res, next);
  } catch (error) {
    if (error instanceof AppError) {
      next(error);
      return;
    }

    console.log('🔐 Auth error:', error instanceof Error ? error.message : String(error));
    next(new AppError(401, "UNAUTHORIZED", "Invalid access token"));
  }
}
