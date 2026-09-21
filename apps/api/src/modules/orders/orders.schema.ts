import { z } from "zod";

export const orderItemSchema = z.object({
  product_id: z.string().uuid(),
  quantity: z.number().int().min(1).max(5),
});

export const createOrderSchema = z.object({
  quote_id: z.string().uuid(),
  items: z.array(orderItemSchema).min(1).max(10),
  delivery_address_id: z.string().uuid(),
  payment_method: z.enum([
    "gold_balance",
    "upi",
    "card",
    "netbanking",
    "cod",
  ]),
  payment_method_id: z.string().uuid().nullable().optional(),
  use_gold_balance_grams: z
    .string()
    .regex(/^\d+\.\d{4}$/)
    .optional(),
});

export const listOrdersQuerySchema = z.object({
  status: z
    .enum([
      "pending_payment",
      "confirmed",
      "shipped",
      "delivered",
      "cancelled",
      "all",
    ])
    .default("all"),
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export const cancelOrderSchema = z.object({
  reason: z.string().trim().min(1).max(500),
});

export type CreateOrderInput = z.infer<typeof createOrderSchema>;
export type ListOrdersQuery = z.infer<typeof listOrdersQuerySchema>;
