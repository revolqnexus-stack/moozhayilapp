import { prisma } from "../../db/prisma";
import {
  applyPaymentCaptureByProviderOrder,
  applyPaymentFailure,
} from "../../modules/payments/payment_completion.service";
import { processRefundCompleted } from "./refund.processor";

export async function processPaymentWebhookEvent(eventId: string): Promise<void> {
  const event = await prisma.webhookEvent.findUnique({
    where: { id: eventId },
  });

  if (!event || !event.signatureValid) {
    return;
  }

  await prisma.webhookEvent.update({
    where: { id: eventId },
    data: { status: "processing" },
  });

  try {
    const payload = event.payload as {
      type?: string;
      data?: {
        order?: {
          order_id?: string;
          order_status?: string;
        };
        payment?: {
          cf_payment_id?: number;
          payment_status?: string;
          payment_amount?: number;
        };
      };
      // Legacy Razorpay format (for historical webhooks)
      event?: string;
      payload?: {
        payment?: {
          entity?: {
            order_id?: string;
            id?: string;
            status?: string;
          };
        };
        refund?: {
          entity?: {
            payment_id?: string;
            id?: string;
            status?: string;
          };
        };
      };
    };

    // Handle Cashfree PAYMENT_SUCCESS_WEBHOOK
    if (payload.type === "PAYMENT_SUCCESS_WEBHOOK") {
      const orderId = payload.data?.order?.order_id;
      const paymentId = payload.data?.payment?.cf_payment_id?.toString();

      if (orderId) {
        await applyPaymentCaptureByProviderOrder({
          providerOrderId: orderId,
          providerPaymentId: paymentId,
          finalStatus: "captured",
        });
      }
    }

    // Handle Cashfree PAYMENT_FAILED_WEBHOOK
    if (payload.type === "PAYMENT_FAILED_WEBHOOK") {
      const orderId = payload.data?.order?.order_id;
      if (orderId) {
        await applyPaymentFailure(orderId);
      }
    }

    // Handle Cashfree REFUND_STATUS_WEBHOOK
    if (payload.type === "REFUND_STATUS_WEBHOOK") {
      const orderId = payload.data?.order?.order_id;
      if (orderId) {
        const paymentTx = await prisma.paymentTransaction.findFirst({
          where: { providerOrderId: orderId },
        });

        if (paymentTx) {
          const order = await prisma.order.findFirst({
            where: { paymentTransactionId: paymentTx.id },
          });

          if (order) {
            await processRefundCompleted(order.id);
          }
        }
      }
    }

    // Legacy Razorpay support (for historical webhooks)
    if (payload.event === "payment.captured") {
      const providerOrderId = payload.payload?.payment?.entity?.order_id;
      const providerPaymentId = payload.payload?.payment?.entity?.id;

      if (providerOrderId) {
        await applyPaymentCaptureByProviderOrder({
          providerOrderId,
          providerPaymentId,
          finalStatus: "captured",
        });
      }
    }

    if (payload.event === "payment.failed") {
      const providerOrderId = payload.payload?.payment?.entity?.order_id;
      if (providerOrderId) {
        await applyPaymentFailure(providerOrderId);
      }
    }

    if (payload.event === "refund.processed") {
      const providerPaymentId = payload.payload?.refund?.entity?.payment_id;
      if (providerPaymentId) {
        const paymentTx = await prisma.paymentTransaction.findFirst({
          where: { providerPaymentId },
        });

        if (paymentTx) {
          const order = await prisma.order.findFirst({
            where: { paymentTransactionId: paymentTx.id },
          });

          if (order) {
            await processRefundCompleted(order.id);
          }
        }
      }
    }

    await prisma.webhookEvent.update({
      where: { id: eventId },
      data: { status: "processed", processedAt: new Date() },
    });
  } catch (error) {
    await prisma.webhookEvent.update({
      where: { id: eventId },
      data: {
        status: "failed",
        errorMessage: error instanceof Error ? error.message : "Webhook failed",
      },
    });
  }
}

export async function processMockWebhookCapture(paymentTransactionId: string) {
  const paymentTx = await prisma.paymentTransaction.findUnique({
    where: { id: paymentTransactionId },
  });

  if (!paymentTx?.providerOrderId) {
    return;
  }

  await processPaymentWebhookEvent(
    (
      await prisma.webhookEvent.create({
        data: {
          provider: "cashfree",
          providerEventId: `mock_evt_${paymentTransactionId}`,
          eventType: "PAYMENT_SUCCESS_WEBHOOK",
          status: "received",
          payload: {
            type: "PAYMENT_SUCCESS_WEBHOOK",
            data: {
              order: {
                order_id: paymentTx.providerOrderId,
                order_status: "PAID",
              },
              payment: {
                cf_payment_id: Date.now(),
                payment_status: "SUCCESS",
                payment_amount: paymentTx.amountPaise / 100,
              },
            },
          },
          signatureValid: true,
          receivedAt: new Date(),
        },
      })
    ).id,
  );
}
