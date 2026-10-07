import { loadEnv } from "../../config/env";
import { AppError } from "../../middleware/error.middleware";
import { logger } from "../../utils/logger";
import { withRetry } from "../../utils/retry";

const MSG91_OTP_URL = "https://control.msg91.com/api/v5/otp";

function requireMsg91Credentials() {
  const env = loadEnv();

  if (!env.MSG91_AUTH_KEY || !env.MSG91_OTP_TEMPLATE_ID) {
    throw new AppError(
      503,
      "PROVIDER_UNAVAILABLE",
      "SMS provider credentials are not configured",
    );
  }

  return {
    authKey: env.MSG91_AUTH_KEY,
    templateId: env.MSG91_OTP_TEMPLATE_ID,
  };
}

/** MSG91 expects mobile as 91XXXXXXXXXX (no + prefix). */
export function formatPhoneForMsg91(phone: string): string {
  const digits = phone.replace(/\D/g, "");
  if (digits.length === 10) {
    return `91${digits}`;
  }
  if (digits.length === 12 && digits.startsWith("91")) {
    return digits;
  }

  throw new AppError(
    422,
    "UNPROCESSABLE",
    "Enter a valid Indian phone number",
  );
}

export async function sendMsg91Otp(input: {
  phone: string;
  otp: string;
}): Promise<void> {
  const env = loadEnv();
  const { authKey, templateId } = requireMsg91Credentials();
  const mobile = formatPhoneForMsg91(input.phone);

  const payload: Record<string, string | number> = {
    template_id: templateId,
    mobile,
    otp: input.otp,
    otp_length: 6,
    otp_expiry: 10,
  };
  if (env.MSG91_SENDER_ID) {
    payload.sender = env.MSG91_SENDER_ID;
  }
  if (env.MSG91_DLT_PE_ID) {
    payload.PE_ID = env.MSG91_DLT_PE_ID;
  }
  if (env.MSG91_DLT_TE_ID) {
    payload.DLT_TE_ID = env.MSG91_DLT_TE_ID;
  }

  await withRetry(async () => {
    const response = await fetch(MSG91_OTP_URL, {
      method: "POST",
      headers: {
        authkey: authKey,
        "content-type": "application/json",
        accept: "application/json",
      },
      body: JSON.stringify(payload),
    });

    const rawBody = await response.text().catch(() => "");

    if (!response.ok) {
      throw new Error(
        `MSG91 OTP request failed (${response.status}): ${rawBody.slice(0, 200)}`,
      );
    }

    let payload: unknown;
    try {
      payload = rawBody ? JSON.parse(rawBody) : null;
    } catch {
      throw new Error(`MSG91 OTP invalid JSON: ${rawBody.slice(0, 200)}`);
    }

    if (payload && typeof payload === "object" && "type" in payload) {
      const type = String(payload.type);
      if (type === "error") {
        const message =
          "message" in payload && typeof payload.message === "string"
            ? payload.message
            : "MSG91 rejected OTP dispatch";
        throw new Error(message);
      }
      if (type !== "success") {
        throw new Error(`MSG91 unexpected response type: ${type}`);
      }
    }

    const requestId =
      payload &&
      typeof payload === "object" &&
      "message" in payload &&
      typeof payload.message === "string"
        ? payload.message
        : undefined;

    logger.info("MSG91 OTP accepted", {
      mobile: `${mobile.slice(0, 4)}****${mobile.slice(-2)}`,
      requestId,
    });
  });
}
