import { AppError } from "../../middleware/error.middleware";
import { logStampMitraFailure, StampMitraError } from "./stampmitra.client";

export function mapStampMitraErrorToAppError(
  error: unknown,
  context: {
    operation: string;
    requiredScope: string;
  },
): AppError {
  if (!(error instanceof StampMitraError)) {
    return new AppError(
      503,
      "PROVIDER_UNAVAILABLE",
      "Verification is temporarily unavailable. Please try again shortly.",
    );
  }

  logStampMitraFailure({
    operation: context.operation,
    requestId: error.requestId,
    status: error.status,
    code: error.code,
  });

  switch (error.status) {
    case 400:
      return new AppError(400, "BAD_REQUEST", error.message, {
        stampmitra_request_id: error.requestId,
      });
    case 401:
      return new AppError(
        503,
        "PROVIDER_UNAVAILABLE",
        "Verification is temporarily unavailable. Please try again later.",
        { stampmitra_request_id: error.requestId },
      );
    case 402:
      logStampMitraFailure({
        operation: `${context.operation}_wallet`,
        requestId: error.requestId,
        status: 402,
        code: error.code,
      });
      return new AppError(
        503,
        "PROVIDER_UNAVAILABLE",
        "Verification is temporarily unavailable. Please try again later.",
        {
          stampmitra_request_id: error.requestId,
          operational_alert: "STAMPMITRA_WALLET_BALANCE",
        },
      );
    case 403:
      return new AppError(403, "FORBIDDEN", error.message, {
        stampmitra_request_id: error.requestId,
        required_scope: context.requiredScope,
      });
    case 404:
      return new AppError(404, "NOT_FOUND", error.message, {
        stampmitra_request_id: error.requestId,
      });
    case 429:
      return new AppError(
        429,
        "RATE_LIMITED",
        "Too many verification attempts. Please try again shortly.",
        { stampmitra_request_id: error.requestId },
      );
    default:
      return new AppError(
        503,
        "PROVIDER_UNAVAILABLE",
        "Verification is temporarily unavailable. Please try again shortly.",
        { stampmitra_request_id: error.requestId },
      );
  }
}
