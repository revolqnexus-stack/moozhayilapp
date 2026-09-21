import type { PaymentTransaction } from "@prisma/client";
import Decimal from "decimal.js";
import { prisma } from "../../db/prisma";
import { contributionsService } from "../contributions/contributions.service";
import { confirmInventoryForOrder, releaseInventoryForOrder } from "../inventory/inventory.service";
import { goldLedgerService } from "../gold_ledger/gold_ledger.service";
import { goldBalanceService } from "../gold_ledger/gold_balance.service";
import { notifyOrderConfirmed } from "../notifications/notifications.triggers";
import { formatPaise } from "../../utils/money";

export async function applyPaymentCapture(input: {
  paymentTransactionId: string;
  providerPaymentId?: string;
  finalStatus?: "captured" | "reconciled";
}): Promise<void> {
  const paymentTx = await prisma.paymentTransaction.findUnique({
    where: { id: input.paymentTransactionId },
  });

  if (!paymentTx) {
    return;
  }

  const alreadySettled =
    paymentTx.status === "captured" ||
    paymentTx.status === "reconciled" ||
    paymentTx.status === "refunded";

  if (!alreadySettled) {
    await prisma.paymentTransaction.update({
      where: { id: paymentTx.id },
      data: {
        status: input.finalStatus ?? "captured",
        providerPaymentId:
          input.providerPaymentId ?? paymentTx.providerPaymentId,
      },
    });
  }

  await completePaymentSideEffects({
    ...paymentTx,
    status: input.finalStatus ?? "captured",
    providerPaymentId:
      input.providerPaymentId ?? paymentTx.providerPaymentId,
  });
}

export async function applyPaymentFailure(providerOrderId: string): Promise<void> {
  const paymentTx = await prisma.paymentTransaction.findFirst({
    where: { providerOrderId },
  });

  if (!paymentTx) {
    return;
  }

  if (
    paymentTx.status === "captured" ||
    paymentTx.status === "reconciled" ||
    paymentTx.status === "refunded"
  ) {
    return;
  }

  await prisma.paymentTransaction.update({
    where: { id: paymentTx.id },
    data: { status: "failed" },
  });

  if (paymentTx.type === "goal_contribution") {
    const contribution = await prisma.contribution.findFirst({
      where: { paymentTransactionId: paymentTx.id },
    });

    if (contribution && contribution.status !== "payment_failed") {
      await contributionsService.failContribution(contribution.id);
    }

    return;
  }

  if (paymentTx.type === "order_payment") {
    await expirePendingOrderForPayment(paymentTx.id, "payment_failed");
  }
}

async function completePaymentSideEffects(
  paymentTx: PaymentTransaction,
): Promise<void> {
  if (paymentTx.type === "order_payment") {
    const order = await prisma.order.findFirst({
      where: { paymentTransactionId: paymentTx.id },
    });

    if (order) {
      await prisma.$transaction(async (tx) => {
        await confirmInventoryForOrder(order.id, tx);
        await tx.order.updateMany({
          where: {
            id: order.id,
            status: "pending_payment",
          },
          data: { status: "confirmed" },
        });
      });
    }

    const orders = await prisma.order.findMany({
      where: { paymentTransactionId: paymentTx.id },
    });

    for (const order of orders) {
      if (order.status === "confirmed") {
        await notifyOrderConfirmed({
          userId: order.userId,
          orderId: order.id,
          orderNumber: order.orderNumber,
          totalDisplay: formatPaise(order.totalPaise),
        });
      }
    }

    return;
  }

  if (paymentTx.type === "goal_contribution") {
    const contribution = await prisma.contribution.findFirst({
      where: { paymentTransactionId: paymentTx.id },
    });

    if (contribution && contribution.status !== "completed") {
      await contributionsService.completeContribution({
        contributionId: contribution.id,
      });
    }
  }
}

export async function applyPaymentCaptureByProviderOrder(input: {
  providerOrderId: string;
  providerPaymentId?: string;
  providerAmountPaise?: number;
  finalStatus?: "captured" | "reconciled";
}): Promise<void> {
  const paymentTx = await prisma.paymentTransaction.findFirst({
    where: { providerOrderId: input.providerOrderId },
  });

  if (!paymentTx) {
    return;
  }

  if (
    input.providerAmountPaise != null &&
    input.providerAmountPaise !== paymentTx.amountPaise
  ) {
    return;
  }

  await applyPaymentCapture({
    paymentTransactionId: paymentTx.id,
    providerPaymentId: input.providerPaymentId,
    finalStatus: input.finalStatus,
  });
}

export async function expirePendingOrderForPayment(
  paymentTransactionId: string,
  reason: string,
): Promise<boolean> {
  const order = await prisma.order.findFirst({
    where: {
      paymentTransactionId,
      status: "pending_payment",
    },
  });

  if (!order) {
    return false;
  }

  const now = new Date();

  await prisma.$transaction(async (tx) => {
    await releaseInventoryForOrder(order.id, "expired", tx);

    const goldUsed = new Decimal(order.goldBalanceUsedGrams.toString());
    if (goldUsed.gt(0)) {
      await goldLedgerService.postRefundCredit({
        userId: order.userId,
        orderId: order.id,
        gramsDelta: goldUsed,
        amountPaise: order.totalPaise,
        goldRatePerGramPaise: order.goldRateAtOrderPaise,
        tx,
      });
    }

    await tx.order.update({
      where: { id: order.id },
      data: {
        status: "cancelled",
        cancelledAt: now,
        cancellationReason: reason,
      },
    });

    await tx.paymentTransaction.updateMany({
      where: {
        id: paymentTransactionId,
        status: { in: ["created", "pending", "failed"] },
      },
      data: { status: "failed" },
    });
  });

  if (new Decimal(order.goldBalanceUsedGrams.toString()).gt(0)) {
    await goldBalanceService.refreshSnapshot(order.userId, "refund");
  }

  return true;
}
