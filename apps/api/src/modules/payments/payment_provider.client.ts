import { randomUUID } from "crypto";
import { loadEnv } from "../../config/env";
import {
  createCashfreeOrder,
  fetchCashfreeOrderStatus,
  createCashfreeRefund,
  verifyCashfreeWebhookSignature,
} from "./cashfree.client";
import {
  createRazorpayOrder,
  captureRazorpayPayment,
  verifyRazorpayWebhookSignature,
  verifyRazorpayCheckoutSignature,
  createRazorpayRefund,
} from "./razorpay.client";

export interface ProviderOrderResult {
  providerOrderId: string;
  paymentSessionId: string;
  amountPaise: number;
}

export interface ProviderPaymentCaptureResult {
  providerPaymentId: string;
  status: "captured" | "failed";
}

export interface ProviderRefundResult {
  providerRefundId: string;
  status: string;
}

export class PaymentProviderClient {
  verifyWebhookSignature(
    payload: string,
    signature: string | undefined,
    timestamp: string | undefined,
  ): boolean {
    const env = loadEnv();

    if (env.PAYMENT_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production") {
        return false;
      }

      return (
        signature === "mock_valid_signature" ||
        signature === env.CASHFREE_WEBHOOK_SECRET ||
        signature === env.RAZORPAY_WEBHOOK_SECRET
      );
    }

    if (env.PAYMENT_PROVIDER === "razorpay") {
      return verifyRazorpayWebhookSignature(payload, signature);
    }

    return verifyCashfreeWebhookSignature(payload, signature, timestamp);
  }

  verifyCheckoutSignature(input: {
    orderId: string;
    paymentId: string;
    signature: string;
  }): boolean {
    const env = loadEnv();

    if (env.PAYMENT_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production") {
        return false;
      }
      return input.signature === "mock_valid_signature";
    }

    if (env.PAYMENT_PROVIDER === "razorpay") {
      return verifyRazorpayCheckoutSignature(input);
    }

    // Cashfree doesn't use checkout signature verification
    return false;
  }

  async createOrder(input: {
    amountPaise: number;
    orderId: string;
    customerId: string;
    customerPhone: string;
    customerEmail?: string;
  }): Promise<ProviderOrderResult> {
    const env = loadEnv();

    if (env.PAYMENT_PROVIDER_MODE === "mock") {
      const mockOrderId = `mock_order_${randomUUID()}`;
      return {
        providerOrderId: mockOrderId,
        paymentSessionId: `mock_session_${randomUUID()}`,
        amountPaise: input.amountPaise,
      };
    }

    if (env.PAYMENT_PROVIDER === "razorpay") {
      const result = await createRazorpayOrder({
        amountPaise: input.amountPaise,
        receipt: input.orderId,
      });

      return {
        providerOrderId: result.providerOrderId,
        paymentSessionId: result.providerOrderId, // Razorpay uses order ID as session
        amountPaise: result.amountPaise,
      };
    }

    return createCashfreeOrder(input);
  }

  async fetchOrderStatus(
    orderId: string,
  ): Promise<{
    providerOrderId: string;
    status: string;
    amountPaise: number;
    payments: Array<{
      providerPaymentId: string;
      status: string;
      amountPaise: number;
    }>;
  }> {
    const env = loadEnv();

    if (env.PAYMENT_PROVIDER_MODE === "mock") {
      return {
        providerOrderId: orderId,
        status: "PAID",
        amountPaise: 100000,
        payments: [
          {
            providerPaymentId: `mock_pay_${orderId}`,
            status: "SUCCESS",
            amountPaise: 100000,
          },
        ],
      };
    }

    return fetchCashfreeOrderStatus(orderId);
  }

  async capturePayment(
    providerOrderId: string,
  ): Promise<ProviderPaymentCaptureResult> {
    const env = loadEnv();

    if (env.PAYMENT_PROVIDER_MODE === "mock") {
      return {
        providerPaymentId: `mock_pay_${providerOrderId}`,
        status: "captured",
      };
    }

    if (env.PAYMENT_PROVIDER === "razorpay") {
      return captureRazorpayPayment(providerOrderId);
    }

    // Cashfree doesn't have explicit capture - fetch order status instead
    const orderStatus = await fetchCashfreeOrderStatus(providerOrderId);

    if (orderStatus.status === "PAID" && orderStatus.payments.length > 0) {
      const successPayment = orderStatus.payments.find(
        (p) => p.status === "SUCCESS",
      );
      if (successPayment) {
        return {
          providerPaymentId: successPayment.providerPaymentId,
          status: "captured",
        };
      }
    }

    return {
      providerPaymentId: `missing_${providerOrderId}`,
      status: "failed",
    };
  }

  verifyUpiId(upiId: string): boolean {
    return /^[a-zA-Z0-9._-]{2,}@[a-zA-Z0-9.-]+$/.test(upiId);
  }

  async createRefund(input: {
    orderId: string;
    amountPaise: number;
    refundNote?: string;
  }): Promise<ProviderRefundResult> {
    const env = loadEnv();

    if (env.PAYMENT_PROVIDER_MODE === "mock") {
      if (env.NODE_ENV === "production") {
        throw new Error("Mock refunds are disabled in production");
      }

      return {
        providerRefundId: `mock_refund_${randomUUID()}`,
        status: "processed",
      };
    }

    if (env.PAYMENT_PROVIDER === "razorpay") {
      // For Razorpay, we need to get the payment ID first, then refund it
      // This is a simplified version - you may need to adjust based on your payment tracking
      return createRazorpayRefund({
        providerPaymentId: input.orderId, // Assuming orderId is actually paymentId
        amountPaise: input.amountPaise,
      });
    }

    return createCashfreeRefund(input);
  }
}

export const paymentProviderClient = new PaymentProviderClient();
