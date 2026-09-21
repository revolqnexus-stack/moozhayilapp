import { loadEnv } from "../../config/env";
import { logger } from "../../utils/logger";
import { sendMsg91Otp } from "./msg91.client";

function maskPhone(phone: string): string {
  if (phone.length < 8) {
    return "***";
  }

  return `${phone.slice(0, 4)}****${phone.slice(-2)}`;
}

export async function sendOtpSms(input: {
  phone: string;
  otp: string;
}): Promise<void> {
  const env = loadEnv();

  if (env.SMS_PROVIDER_MODE === "mock") {
    if (env.NODE_ENV === "development") {
      logger.info("OTP mock SMS", {
        phone: maskPhone(input.phone),
        otp: input.otp,
        provider: "mock",
      });
    } else {
      logger.info("OTP mock SMS dispatched (fixed staging code)", {
        phone: maskPhone(input.phone),
        provider: "mock",
      });
    }

    return;
  }

  await sendMsg91Otp(input);
}
