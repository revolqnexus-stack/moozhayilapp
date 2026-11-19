import { z } from "zod";

export const sendAadhaarOtpSchema = z.object({
  aadhaar_number: z
    .string()
    .regex(/^\d{12}$/, "Aadhaar must be a 12-digit number"),
});

export const verifyAadhaarOtpSchema = z.object({
  session_id: z.string().uuid(),
  otp: z.string().regex(/^\d{6}$/, "OTP must be 6 digits"),
});

const panPattern = /^[A-Z]{5}[0-9]{4}[A-Z]$/;

export const verifyPanSchema = z.object({
  pan_number: z
    .string()
    .transform((value) => value.trim().toUpperCase())
    .pipe(
      z
        .string()
        .regex(panPattern, "Enter a valid PAN (ABCDE1234F)"),
    ),
  name: z
    .string()
    .optional()
    .transform((value) => {
      const trimmed = value?.trim() ?? "";
      return trimmed.length > 0 ? trimmed : undefined;
    })
    .pipe(
      z
        .string()
        .max(256, "Name must be 256 characters or fewer")
        .optional(),
    ),
});

export function isPanNameMismatch(
  name: string | undefined,
  nameMatchResult: string | null,
): boolean {
  if (!name || !nameMatchResult) {
    return false;
  }

  return nameMatchResult.toUpperCase() !== "MATCH";
}

export type SendAadhaarOtpInput = z.infer<typeof sendAadhaarOtpSchema>;
export type VerifyAadhaarOtpInput = z.infer<typeof verifyAadhaarOtpSchema>;
export type VerifyPanInput = z.infer<typeof verifyPanSchema>;

export const verifyBankAccountSchema = z.object({
  account_number: z
    .string()
    .transform((value) => value.replace(/\D/g, ""))
    .pipe(
      z.string().min(12, "Account number is too short").max(20, "Account number is too long"),
    ),
  ifsc: z
    .string()
    .transform((value) => value.toUpperCase())
    .pipe(
      z.string().regex(/^[A-Z]{4}0[A-Z0-9]{6}$/, "Enter a valid IFSC code"),
    ),
  name: z
    .string()
    .optional()
    .transform((value) => {
      const trimmed = value?.trim() ?? "";
      return trimmed.length > 0 ? trimmed : undefined;
    }),
});

export type VerifyBankAccountInput = z.infer<typeof verifyBankAccountSchema>;
