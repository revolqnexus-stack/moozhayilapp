import { loadEnv } from "../../config/env";
import { AppError } from "../../middleware/error.middleware";
import { withRetry } from "../../utils/retry";

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

  async verifyPan(panNumber: string): Promise<PanVerifyResult> {
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
        };
      }

      return {
        verified: true,
        nameOnPan: "MOCK KYC USER",
        panType: "individual",
      };
    }

    const result = await liveKycRequest<{
      verified: boolean;
      name_on_pan: string;
      pan_type: string;
    }>("/pan/verify", { pan_number: panNumber });

    return {
      verified: result.verified,
      nameOnPan: result.name_on_pan,
      panType: result.pan_type,
    };
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
