import { z } from "zod";

export const verifyUpiSchema = z.object({
  upi_id: z.string().trim().min(3).max(100),
});

export const createPaymentMethodSchema = z.object({
  type: z.enum(["upi", "card", "netbanking"]),
  provider_token: z.string().trim().min(1).max(500),
  display_label: z.string().trim().min(1).max(100),
  is_default: z.boolean().optional(),
});

export const reconcilePaymentSchema = z.object({
  payment_transaction_id: z.string().uuid(),
});

export const captureCheckoutSchema = z.object({
  payment_session_id: z.string().uuid(),
  cashfree_order_id: z.string().min(1),
});

export const verifyRazorpaySignatureSchema = z.object({
  razorpay_order_id: z.string().min(1),
  razorpay_payment_id: z.string().min(1),
  razorpay_signature: z.string().min(1),
});

export type VerifyUpiInput = z.infer<typeof verifyUpiSchema>;
export type CreatePaymentMethodInput = z.infer<typeof createPaymentMethodSchema>;
export type CaptureCheckoutInput = z.infer<typeof captureCheckoutSchema>;
export type VerifyRazorpaySignatureInput = z.infer<
  typeof verifyRazorpaySignatureSchema
>;
