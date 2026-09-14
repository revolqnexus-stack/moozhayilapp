import Decimal from "decimal.js";
import { prisma } from "../../db/prisma";
import { releaseInventoryForOrder } from "../../modules/inventory/inventory.service";
import { goldLedgerService } from "../../modules/gold_ledger/gold_ledger.service";
import { goldBalanceService } from "../../modules/gold_ledger/gold_balance.service";
import { paymentProviderClient } from "../../modules/payments/payment_provider.client";
import {
  notifyRefundCompleted,
  notifyRefundInitiated,
} from "../../modules/notifications/notifications.triggers";

export async function processOrderRefund(
  orderId: string,
  reason: string,
): Promise<boolean> {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
    include: { items: true },
  });

  if (!order) {
    return false;
  }

  const now = new Date();
  let refundInitiated = false;

  if (order.paymentTransactionId) {
    const paymentTx = await prisma.paymentTransaction.findUnique({
      where: { id: order.paymentTransactionId },
    });

    if (
      paymentTx?.providerPaymentId &&
      (paymentTx.status === "captured" || paymentTx.status === "reconciled")
    ) {
      await paymentProviderClient.createRefund({
        orderId: paymentTx.providerPaymentId,
        amountPaise: paymentTx.amountPaise,
      });
      refundInitiated = true;
    }
  }

  await prisma.$transaction(async (tx) => {
    await tx.order.update({
      where: { id: order.id },
      data: {
        status: "cancelled",
        cancelledAt: now,
        cancellationReason: reason,
        refundedAt: now,
      },
    });

    await releaseInventoryForOrder(order.id, "released", tx);

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
      refundInitiated = true;
    }

    if (order.paymentTransactionId) {
      await tx.paymentTransaction.update({
        where: { id: order.paymentTransactionId },
        data: { status: "refund_initiated" },
      });
      refundInitiated = true;
    }
  });

  if (new Decimal(order.goldBalanceUsedGrams.toString()).gt(0)) {
    await goldBalanceService.refreshSnapshot(order.userId, "refund");
  }

  if (refundInitiated) {
    await notifyRefundInitiated({
      userId: order.userId,
      orderId: order.id,
      orderNumber: order.orderNumber,
    });
  }

  return refundInitiated;
}

export async function processRefundCompleted(orderId: string): Promise<void> {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
  });

  if (!order) {
    return;
  }

  if (order.paymentTransactionId) {
    await prisma.paymentTransaction.updateMany({
      where: { id: order.paymentTransactionId },
      data: { status: "refunded" },
    });
  }

  await notifyRefundCompleted({
    userId: order.userId,
    orderId: order.id,
    orderNumber: order.orderNumber,
  });
}
