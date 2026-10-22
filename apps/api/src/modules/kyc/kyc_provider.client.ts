import { loadEnv } from "../../config/env";
import { AppError } from "../../middleware/error.middleware";
import { withRetry } from "../../utils/retry";
import { mapStampMitraErrorToAppError } from "./stampmitra.errors";
import { verifyPanWithStampMitra } from "./stampmitra.client";

export interface AadhaarOtpSendResult {
  providerSessionId: string;
}

export interface AadhaarVerifyResult {
  verified: boolean;
  nameOnAadhaar: string;
}

export interface PanVerifyResult {
  verified: boolean;
  nameOnPan: string;
  panType: string;
  referenceId: string;
  panStatus: string;
  nameMatchResult: string;
  message: string;
}

export interface SelfieVerifyResult {
  faceDetected: boolean;
  livenessScore?: number;
}

async function liveKycRequest<T>(
  path: string,
  body: Record<string, unknown>,
): Promise<T> {
  const env = loadEnv();

  if (!env.KYC_PROVIDER_BASE_URL || !env.KYC_PROVIDER_API_KEY) {
    throw new AppError(
      503,
      "PROVIDER_UNAVAILABLE",
      "KYC provider credentials are not configured",
    );
  }

  const url = `${env.KYC_PROVIDER_BASE_URL.replace(/\/$/, "")}${path}`;

  return withRetry(async () => {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.KYC_PROVIDER_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      throw new Error(
        `KYC provider POST ${path} failed (${response.status}): ${errorBody}`,
      );
    }

    return (await response.json()) as T;
  });
}

export class KycProviderClient {
  async sendAadhaarOtp(aadhaarNumber: string): Promise<AadhaarOtpSendResult> {
    const env = loadEnv();
    if (env.KYC_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production" && !env.MOOZHAYIL_ALLOW_MOCK_KYC) {
        throw new AppError(503, "PROVIDER_UNAVAILABLE", "Mock KYC disabled in production");
      }

      if (!/^\d{12}$/.test(aadhaarNumber)) {
        throw new AppError(422, "UNPROCESSABLE", "Invalid Aadhaar number");
      }

      return { providerSessionId: `mock_aadhaar_${aadhaarNumber.slice(-4)}` };
    }

    const result = await liveKycRequest<{ session_id: string }>(
      "/aadhaar/send-otp",
      { aadhaar_number: aadhaarNumber },
    );

    return { providerSessionId: result.session_id };
  }

  async verifyAadhaarOtp(
    aadhaarNumber: string,
    otp: string,
  ): Promise<AadhaarVerifyResult> {
    const env = loadEnv();
    if (env.KYC_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production" && !env.MOOZHAYIL_ALLOW_MOCK_KYC) {
        throw new AppError(503, "PROVIDER_UNAVAILABLE", "Mock KYC disabled in production");
      }

      const expectedOtp =
        process.env.NODE_ENV === "test"
          ? (process.env.TEST_KYC_AADHAAR_OTP ?? "654321")
          : "654321";

      if (otp !== expectedOtp) {
        return { verified: false, nameOnAadhaar: "" };
      }

      return {
        verified: true,
        nameOnAadhaar: "MOCK KYC USER",
      };
    }

    const result = await liveKycRequest<{
      verified: boolean;
      name_on_aadhaar: string;
    }>("/aadhaar/verify-otp", {
      aadhaar_number: aadhaarNumber,
      otp,
    });

    return {
      verified: result.verified,
      nameOnAadhaar: result.name_on_aadhaar,
    };
  }

  async verifyPan(panNumber: string, name?: string): Promise<PanVerifyResult> {
    const env = loadEnv();
    if (env.KYC_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production" && !env.MOOZHAYIL_ALLOW_MOCK_KYC) {
        throw new AppError(503, "PROVIDER_UNAVAILABLE", "Mock KYC disabled in production");
      }

      if (!/^[A-Z]{5}\d{4}[A-Z]$/.test(panNumber)) {
        return {
          verified: false,
          nameOnPan: "",
          panType: "individual",
          referenceId: "mock_pan_invalid_format",
          panStatus: "INVALID",
          nameMatchResult: "",
          message: "Invalid PAN format",
        };
      }

      const mockName = "MOCK KYC USER";
      const nameMatchResult =
        name && name.trim().length > 0 && name.trim().toUpperCase() !== mockName
          ? "MISMATCH"
          : "MATCH";

      return {
        verified: nameMatchResult === "MATCH",
        nameOnPan: mockName,
        panType: "individual",
        referenceId: `mock_pan_${panNumber.slice(-4)}`,
        panStatus: "VALID",
        nameMatchResult,
        message: "PAN is Valid",
      };
    }

    try {
      const result = await verifyPanWithStampMitra({
        pan: panNumber,
        name: name?.trim() || undefined,
      });

      const nameMismatch =
        name &&
        name.trim().length > 0 &&
        result.nameMatchResult &&
        result.nameMatchResult.toUpperCase() !== "MATCH";

      return {
        verified: result.valid && !nameMismatch,
        nameOnPan: result.registeredName,
        panType: "individual",
        referenceId: result.referenceId,
        panStatus: result.panStatus,
        nameMatchResult: result.nameMatchResult,
        message: result.message,
      };
    } catch (error) {
      throw mapStampMitraErrorToAppError(error, {
        operation: "verify_pan",
        requiredScope: "verification.pan.read",
      });
    }
  }

  async verifySelfie(buffer: Buffer, mimeType: string): Promise<SelfieVerifyResult> {
    const env = loadEnv();
    if (env.KYC_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production" && !env.MOOZHAYIL_ALLOW_MOCK_KYC) {
        throw new AppError(503, "PROVIDER_UNAVAILABLE", "Mock KYC disabled in production");
      }

      if (buffer.length === 0) {
        return { faceDetected: false };
      }

      return { faceDetected: true, livenessScore: 1 };
    }

    const result = await liveKycRequest<{
      face_detected: boolean;
      liveness_score?: number;
    }>("/selfie/verify", {
      image_base64: buffer.toString("base64"),
      mime_type: mimeType,
    });

    return {
      faceDetected: result.face_detected,
      livenessScore: result.liveness_score,
    };
  }
}

export const kycProviderClient = new KycProviderClient();
