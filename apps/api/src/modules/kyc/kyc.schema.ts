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

export const verifyPanSchema = z.object({
  pan_number: z
    .string()
    .trim()
    .transform((value) => value.toUpperCase())
    .pipe(z.string().regex(/^[A-Z]{5}\d{4}[A-Z]$/, "PAN must match ABCDE1234F format")),
  name: z
    .string()
    .trim()
    .max(256, "Name must be at most 256 characters")
    .optional()
    .transform((value) => (value && value.length > 0 ? value : undefined)),
});

export type SendAadhaarOtpInput = z.infer<typeof sendAadhaarOtpSchema>;
export type VerifyAadhaarOtpInput = z.infer<typeof verifyAadhaarOtpSchema>;
export type VerifyPanInput = z.infer<typeof verifyPanSchema>;

export const verifyBankAccountSchema = z.object({
  account_number: z
    .string()
    .trim()
    .transform((value) => value.replace(/\D/g, ""))
    .pipe(
      z
        .string()
        .regex(/^\d{9,18}$/, "Account number must be 9 to 18 digits"),
    ),
  ifsc: z
    .string()
    .trim()
    .transform((value) => value.toUpperCase())
    .pipe(
      z
        .string()
        .regex(/^[A-Z]{4}0[A-Z0-9]{6}$/, "IFSC must match format e.g. ICIC0001234"),
    ),
  name: z
    .string()
    .trim()
    .max(256, "Name must be at most 256 characters")
    .optional()
    .transform((value) => (value && value.length > 0 ? value : undefined)),
});

export type VerifyBankAccountInput = z.infer<typeof verifyBankAccountSchema>;
