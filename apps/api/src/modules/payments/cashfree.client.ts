import { createHmac, timingSafeEqual } from "crypto";
import { loadEnv } from "../../config/env";
import { AppError } from "../../middleware/error.middleware";
import { withRetry } from "../../utils/retry";

const CASHFREE_SANDBOX_BASE = "https://sandbox.cashfree.com/pg";
const CASHFREE_PRODUCTION_BASE = "https://api.cashfree.com/pg";
const CASHFREE_API_VERSION = "2022-09-01";

interface CashfreeOrderResponse {
  cf_order_id: string;
  order_id: string;
  entity: string;
  order_currency: string;
  order_amount: number;
  order_status: string;
  payment_session_id: string;
  order_expiry_time: string;
  order_note?: string;
  created_at: string;
}

interface CashfreeOrderStatusResponse {
  cf_order_id: number;
  order_id: string;
  entity: string;
  order_currency: string;
  order_amount: number;
  order_status: "ACTIVE" | "PAID" | "EXPIRED";
  payment_session_id: string;
  order_expiry_time: string;
  created_at: string;
  order_meta?: {
    return_url?: string;
    notify_url?: string;
    payment_methods?: string;
  };
  settlements?: {
    url?: string;
  };
  payments?: {
    url?: string;
  };
  refunds?: {
    url?: string;
  };
  customer_details?: {
    customer_id: string;
    customer_phone: string;
    customer_email?: string;
    customer_name?: string;
  };
}

interface CashfreePayment {
  cf_payment_id: number;
  order_id: string;
  entity: string;
  payment_currency: string;
  payment_amount: number;
  payment_time: string;
  payment_completion_time?: string;
  payment_status: "SUCCESS" | "FAILED" | "PENDING" | "USER_DROPPED";
  payment_message?: string;
  bank_reference?: string;
  auth_id?: string;
  payment_method?: {
    [key: string]: unknown;
  };
}

interface CashfreeRefundResponse {
  cf_refund_id: string;
  cf_payment_id: number;
  refund_id: string;
  order_id: string;
  entity: string;
  refund_amount: number;
  refund_currency: string;
  refund_note?: string;
  refund_status: "SUCCESS" | "PENDING" | "CANCELLED" | "ONHOLD";
  refund_arn?: string;
  refund_charge?: number;
  refund_mode?: string;
  refund_type: "MERCHANT_INITIATED" | "UNRECONCILED_AUTO_REFUND";
  processed_at?: string;
  created_at: string;
}

function requireCashfreeCredentials() {
  const env = loadEnv();

  if (!env.CASHFREE_APP_ID || !env.CASHFREE_SECRET_KEY) {
    throw new AppError(
      503,
      "PROVIDER_UNAVAILABLE",
      "Cashfree credentials are not configured",
    );
  }

  const baseUrl =
    env.CASHFREE_ENVIRONMENT === "production"
      ? CASHFREE_PRODUCTION_BASE
      : CASHFREE_SANDBOX_BASE;

  return {
    appId: env.CASHFREE_APP_ID,
    secretKey: env.CASHFREE_SECRET_KEY,
    webhookSecret: env.CASHFREE_WEBHOOK_SECRET,
    baseUrl,
  };
}

async function cashfreeRequest<T>(
  method: "GET" | "POST",
  path: string,
  body?: Record<string, unknown>,
): Promise<T> {
  const { appId, secretKey, baseUrl } = requireCashfreeCredentials();

  return withRetry(async () => {
    const response = await fetch(`${baseUrl}${path}`, {
      method,
      headers: {
        "x-client-id": appId,
        "x-client-secret": secretKey,
        "x-api-version": CASHFREE_API_VERSION,
        "Content-Type": "application/json",
      },
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const errorBody = await response.text();
      throw new Error(
        `Cashfree ${method} ${path} failed (${response.status}): ${errorBody}`,
      );
    }

    return (await response.json()) as T;
  });
}

export async function createCashfreeOrder(input: {
  amountPaise: number;
  orderId: string;
  customerId: string;
  customerPhone: string;
  customerEmail?: string;
}): Promise<{
  providerOrderId: string;
  paymentSessionId: string;
  amountPaise: number;
}> {
  // Cashfree requires amount in rupees (decimal), not paise
  const amountRupees = input.amountPaise / 100;

  const order = await cashfreeRequest<CashfreeOrderResponse>("POST", "/orders", {
    order_id: input.orderId,
    order_amount: amountRupees,
    order_currency: "INR",
    customer_details: {
      customer_id: input.customerId,
      customer_phone: input.customerPhone,
      ...(input.customerEmail && { customer_email: input.customerEmail }),
    },
    order_meta: {
      notify_url: `${loadEnv().PUBLIC_BASE_URL}/v1/webhooks/payment`,
    },
  });

  return {
    providerOrderId: order.cf_order_id.toString(),
    paymentSessionId: order.payment_session_id,
    amountPaise: Math.round(order.order_amount * 100),
  };
}

export async function fetchCashfreeOrderStatus(
  orderId: string,
): Promise<{
  providerOrderId: string;
  status: "ACTIVE" | "PAID" | "EXPIRED";
  amountPaise: number;
  payments: Array<{
    providerPaymentId: string;
    status: "SUCCESS" | "FAILED" | "PENDING" | "USER_DROPPED";
    amountPaise: number;
  }>;
}> {
  const orderStatus = await cashfreeRequest<CashfreeOrderStatusResponse>(
    "GET",
    `/orders/${orderId}`,
  );

  // Fetch associated payments
  let payments: CashfreePayment[] = [];
  if (orderStatus.payments?.url) {
    try {
      const paymentsResponse = await cashfreeRequest<{
        [key: string]: unknown;
      }>("GET", `/orders/${orderId}/payments`);
      payments = (paymentsResponse as unknown as CashfreePayment[]) || [];
    } catch (error) {
      // Payments endpoint might not exist if no payment attempts yet
      console.warn(`Failed to fetch payments for order ${orderId}:`, error);
    }
  }

  return {
    providerOrderId: orderStatus.cf_order_id.toString(),
    status: orderStatus.order_status,
    amountPaise: Math.round(orderStatus.order_amount * 100),
    payments: payments.map((payment) => ({
      providerPaymentId: payment.cf_payment_id.toString(),
      status: payment.payment_status,
      amountPaise: Math.round(payment.payment_amount * 100),
    })),
  };
}

export async function createCashfreeRefund(input: {
  orderId: string;
  amountPaise: number;
  refundNote?: string;
}): Promise<{
  providerRefundId: string;
  status: string;
}> {
  const amountRupees = input.amountPaise / 100;

  const refund = await cashfreeRequest<CashfreeRefundResponse>(
    "POST",
    `/orders/${input.orderId}/refunds`,
    {
      refund_amount: amountRupees,
      refund_id: `refund_${Date.now()}`,
      refund_note: input.refundNote || "Refund initiated by admin",
    },
  );

  return {
    providerRefundId: refund.cf_refund_id,
    status: refund.refund_status,
  };
}

export function verifyCashfreeWebhookSignature(
  rawBody: string,
  signature: string | undefined,
  timestamp: string | undefined,
): boolean {
  const { webhookSecret } = requireCashfreeCredentials();

  if (!signature || !timestamp || !webhookSecret) {
    return false;
  }

  // Cashfree signature format: base64(sha256(rawBody + timestamp + secretKey))
  const signatureData = rawBody + timestamp + webhookSecret;
  const expected = createHmac("sha256", webhookSecret)
    .update(signatureData)
    .digest("base64");

  const expectedBuffer = Buffer.from(expected, "utf8");
  const signatureBuffer = Buffer.from(signature, "utf8");

  if (expectedBuffer.length !== signatureBuffer.length) {
    return false;
  }

  return timingSafeEqual(expectedBuffer, signatureBuffer);
}

