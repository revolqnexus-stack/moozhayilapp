import type { NextFunction, Request, Response } from "express";
import { ZodError } from "zod";
import { getRequestId } from "./request_id.middleware";
import { captureException } from "../utils/monitoring";

export type ErrorCode =
  | "BAD_REQUEST"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "KYC_REQUIRED"
  | "ENHANCED_KYC_REQUIRED"
  | "NOT_FOUND"
  | "CONFLICT"
  | "PRICE_CHANGED"
  | "PRICE_EXPIRED"
  | "OUT_OF_STOCK"
  | "INSUFFICIENT_BALANCE"
  | "UNPROCESSABLE"
  | "RATE_LIMITED"
  | "SERVER_ERROR"
  | "PROVIDER_UNAVAILABLE"
  | "PAYMENT_NOT_COMPLETED"
  | "PAYMENT_NOT_SUCCESSFUL"
  | "INVALID_SIGNATURE";

export interface ApiErrorBody {
  error: {
    code: ErrorCode;
    message: string;
    details?: Record<string, unknown>;
    request_id: string;
  };
}

export class AppError extends Error {
  readonly statusCode: number;
  readonly code: ErrorCode;
  readonly details?: Record<string, unknown>;

  constructor(
    statusCode: number,
    code: ErrorCode,
    message: string,
    details?: Record<string, unknown>,
  ) {
    super(message);
    this.name = "AppError";
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }
}

export function buildErrorResponse(
  req: Request,
  code: ErrorCode,
  message: string,
  details?: Record<string, unknown>,
): ApiErrorBody {
  return {
    error: {
      code,
      message,
      ...(details ? { details } : {}),
      request_id: getRequestId(req),
    },
  };
}

export function errorMiddleware(
  err: unknown,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  console.error('❌ Error caught in middleware:', {
    path: req.path,
    method: req.method,
    error: err instanceof Error ? err.message : String(err),
    stack: err instanceof Error ? err.stack : undefined,
  });

  if (err instanceof AppError) {
    console.error('❌ AppError:', err.code, err.message, err.details);
    res.status(err.statusCode).json(
      buildErrorResponse(req, err.code, err.message, err.details),
    );
    return;
  }

  if (err instanceof ZodError) {
    console.error('❌ ZodError:', JSON.stringify(err.flatten().fieldErrors));
    res.status(422).json(
      buildErrorResponse(req, "UNPROCESSABLE", "Validation error", {
        fields: err.flatten().fieldErrors,
      }),
    );
    return;
  }

  captureException(err, { path: req.path, method: req.method });

  // TEMPORARY (remove once KYC PAN is stable): Render logs are not available,
  // so surface the real cause for KYC routes only. No stack trace is sent.
  if (req.originalUrl.includes("/kyc/")) {
    const name = err instanceof Error ? err.name : "Error";
    const message = err instanceof Error ? err.message : String(err);
    res.status(500).json(
      buildErrorResponse(
        req,
        "SERVER_ERROR",
        `Server error: ${name}: ${message.slice(0, 300)}`,
      ),
    );
    return;
  }

  res.status(500).json(
    buildErrorResponse(req, "SERVER_ERROR", "An unexpected error occurred"),
  );
}

export function notFoundHandler(req: Request, res: Response): void {
  res
    .status(404)
    .json(buildErrorResponse(req, "NOT_FOUND", "Resource does not exist"));
}
