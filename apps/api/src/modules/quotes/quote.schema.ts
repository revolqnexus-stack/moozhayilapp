import { z } from "zod";
import { orderItemSchema } from "../orders/orders.schema";

export const createQuoteSchema = z.object({
  items: z.array(orderItemSchema).min(1).max(10).optional(),
});

export type CreateQuoteInput = z.infer<typeof createQuoteSchema>;
