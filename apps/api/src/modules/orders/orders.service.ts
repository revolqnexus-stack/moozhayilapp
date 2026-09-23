import Decimal from "decimal.js";
import type { KycStatus } from "@prisma/client";
import { prisma } from "../../db/prisma";
import { SAR_THRESHOLD_PAISE } from "../../config/admin.constants";
import { loadEnv } from "../../config/env";
import { applyPaymentCapture } from "../payments/payment_completion.service";
import { AppError } from "../../middleware/error.middleware";
import {
  COD_MAX_ORDER_PAISE,
  CANCELLABLE_ORDER_STATUSES,
  INVENTORY_RESERVATION_TTL_MINUTES,
} from "../../config/orders.constants";
import { withIdempotency } from "../../utils/idempotency";
import {
  calculateGramsFromPaise,
  calculateValuePaiseFromGrams,
} from "../../utils/gold";
import { assertKycGate, checkCheckoutGate } from "../../utils/kyc_gates";
import { goldLedgerService } from "../gold_ledger/gold_ledger.service";
import { goldBalanceService } from "../gold_ledger/gold_balance.service";
import { type AuraProductPriceDto } from "../goals/aura.mc_waiver.service";
import {
  mapProductToDto,
  productInclude,
  type ProductWithRelations,
} from "../products/product.mapper";
import { paymentProviderClient } from "../payments/payment_provider.client";
import { quoteService } from "../quotes/quote.service";
import type { ResolvedQuote } from "../quotes/quote.types";
import { generateOrderNumber, mapOrderToDto } from "./order.mapper";
import { formatPaise } from "../../utils/money";
import type { CreateOrderInput, ListOrdersQuery } from "./orders.schema";
import { processOrderRefund } from "../../jobs/processors/refund.processor";
import {
  notifyOrderConfirmed,
  notifyOrderDelivered,
  notifyOrderShipped,
} from "../notifications/notifications.triggers";
import { assertAvailableStock } from "../inventory/inventory.service";

interface PricedLine {
  product: ProductWithRelations;
  quantity: number;
  price: AuraProductPriceDto;
  productDto: Awaited<ReturnType<typeof mapProductToDto>>;
}

export class OrdersService {
  async list(userId: string, query: ListOrdersQuery) {
    const where = {
      userId,
      ...(query.status !== "all" ? { status: query.status } : {}),
    };

    const rows = await prisma.order.findMany({
      where,
      include: { items: true },
      orderBy: { createdAt: "desc" },
      take: query.limit + 1,
      ...(query.cursor
        ? { cursor: { id: query.cursor }, skip: 1 }
        : {}),
    });

    const hasMore = rows.length > query.limit;
    const data = hasMore ? rows.slice(0, query.limit) : rows;

    return {
      data: data.map(mapOrderToDto),
      next_cursor: hasMore ? data[data.length - 1]?.id ?? null : null,
      has_more: hasMore,
    };
  }

  async getById(userId: string, orderId: string) {
    const order = await prisma.order.findFirst({
      where: { id: orderId, userId },
      include: { items: true },
    });

    if (!order) {
      throw new AppError(404, "NOT_FOUND", "Order does not exist");
    }

    const goldAppliedPaise = calculateValuePaiseFromGrams(
      order.goldBalanceUsedGrams,
      order.goldRateAtOrderPaise,
    );

    return {
      order: mapOrderToDto(order),
      payment_breakdown: {
        total_paise: order.totalPaise,
        gold_applied_paise: goldAppliedPaise,
        cash_paid_paise: Math.max(order.totalPaise - goldAppliedPaise, 0),
        gold_rate_paise: order.goldRateAtOrderPaise,
      },
    };
  }

  async create(
    userId: string,
    kycStatus: KycStatus,
    input: CreateOrderInput,
    idempotencyKey: string,
  ) {
    return withIdempotency({
      userId,
      scope: "orders.create",
      key: idempotencyKey,
      requestBody: input,
      resourceType: "order",
      handler: async () => this.createOrder(userId, kycStatus, input),
    });
  }

  private async createOrder(
    userId: string,
    kycStatus: KycStatus,
    input: CreateOrderInput,
  ) {
    const address = await prisma.address.findFirst({
      where: { id: input.delivery_address_id, userId, deletedAt: null },
    });

    if (!address) {
      throw new AppError(404, "NOT_FOUND", "Delivery address does not exist");
    }

    if (input.payment_method === "cod" && input.use_gold_balance_grams) {
      throw new AppError(
        422,
        "UNPROCESSABLE",
        "Cash on delivery cannot be combined with gold balance",
      );
    }

    const usesGoldIntent =
      input.payment_method === "gold_balance" ||
      Boolean(input.use_gold_balance_grams);

    const resolved = await quoteService.resolveForOrder(
      userId,
      input.quote_id,
      input.items,
    );
    const totals = resolved.totals;
    const lines = await this.linesFromResolvedQuote(resolved);
    const auraMcWaiverGoal = resolved.auraPlanGoalId
      ? { id: resolved.auraPlanGoalId }
      : null;

    assertKycGate(
      checkCheckoutGate(kycStatus, totals.totalPaise, usesGoldIntent),
      kycStatus,
    );

    const rate = { ratePerGramPaise: resolved.goldRateAtQuotePaise };

    if (input.payment_method === "cod") {
      if (totals.totalPaise > COD_MAX_ORDER_PAISE) {
        throw new AppError(
          422,
          "UNPROCESSABLE",
          "Cash on delivery is only available for orders below ₹25,000",
        );
      }
      if (usesGoldIntent) {
        throw new AppError(
          422,
          "UNPROCESSABLE",
          "Cash on delivery cannot be used with gold balance",
        );
      }
    }

    let goldGramsToUse = new Decimal(0);
    if (input.payment_method === "gold_balance") {
      const balance = await goldLedgerService.getPostedBalanceGrams(userId);
      const gramsNeeded = calculateGramsFromPaise(
        totals.totalPaise,
        rate.ratePerGramPaise,
      );
      goldGramsToUse = Decimal.min(balance, gramsNeeded);
    } else if (input.use_gold_balance_grams) {
      goldGramsToUse = new Decimal(input.use_gold_balance_grams);
    }

    const goldAppliedPaise = calculateValuePaiseFromGrams(
      goldGramsToUse,
      rate.ratePerGramPaise,
    );
    const paymentAmountPaise = Math.max(totals.totalPaise - goldAppliedPaise, 0);

    if (goldGramsToUse.gt(0)) {
      const balance = await goldLedgerService.getPostedBalanceGrams(userId);
      if (balance.lt(goldGramsToUse)) {
        throw new AppError(
          422,
          "INSUFFICIENT_BALANCE",
          "Insufficient gold balance for redemption",
        );
      }
    }

    const orderNumber = await generateOrderNumber();
    const now = new Date();
    const expiresAt = new Date(
      now.getTime() + INVENTORY_RESERVATION_TTL_MINUTES * 60 * 1000,
    );

    const addressSnapshot = {
      id: address.id,
      full_name: address.fullName,
      phone: address.phone,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
    };

    const env = loadEnv();
    let paymentSessionId: string | null = null;
    let paymentUrl: string | null = null;
    let razorpayOrderId: string | null = null;

    const requiresOnlinePayment =
      paymentAmountPaise > 0 && input.payment_method !== "cod";
    const confirmsImmediately = !requiresOnlinePayment;

    const result = await prisma.$transaction(async (tx) => {
      for (const line of lines) {
        try {
          await assertAvailableStock(
            line.product.id,
            line.product.stockQuantity,
            line.quantity,
            tx,
          );
        } catch {
          throw new AppError(400, "OUT_OF_STOCK", "Product is out of stock");
        }

        if (confirmsImmediately) {
          const updated = await tx.product.updateMany({
            where: {
              id: line.product.id,
              stockQuantity: { gte: line.quantity },
            },
            data: { stockQuantity: { decrement: line.quantity } },
          });

          if (updated.count === 0) {
            throw new AppError(400, "OUT_OF_STOCK", "Product is out of stock");
          }
        }
      }

      const order = await tx.order.create({
        data: {
          orderNumber,
          userId,
          status: requiresOnlinePayment ? "pending_payment" : "confirmed",
          totalPaise: totals.totalPaise,
          goldValuePaise: totals.goldValuePaise,
          makingChargesPaise: totals.makingChargesPaise,
          wastagePaise: totals.wastagePaise,
          stoneValuePaise: totals.stoneValuePaise,
          gstPaise: totals.gstPaise,
          makingChargeWaiverPaise: totals.makingChargeWaiverPaise,
          auraPlanGoalId: auraMcWaiverGoal?.id ?? null,
          deliveryAddressId: address.id,
          deliveryAddressSnapshot: addressSnapshot,
          paymentMethod: input.payment_method,
          goldBalanceUsedGrams: goldGramsToUse.toFixed(4),
          goldRateAtOrderPaise: rate.ratePerGramPaise,
          priceQuoteId: resolved.quoteId,
        },
      });

      await quoteService.markConsumed(resolved.quoteId, order.id, tx);

      for (const line of lines) {
        await tx.orderItem.create({
          data: {
            orderId: order.id,
            productId: line.product.id,
            productSnapshot: {
              id: line.product.id,
              name: line.product.name,
              sku: line.product.sku,
              primary_image: line.productDto.primary_image,
            },
            quantity: line.quantity,
            unitPricePaise: line.price.total_paise,
            weightGrams: line.product.weightGrams.toString(),
            goldRatePaise: line.price.rate_used_paise,
          },
        });

        await tx.inventoryReservation.create({
          data: {
            productId: line.product.id,
            userId,
            orderId: order.id,
            quantity: line.quantity,
            status: confirmsImmediately ? "confirmed" : "reserved",
            reservedAt: now,
            expiresAt,
            confirmedAt: confirmsImmediately ? now : null,
          },
        });
      }

      if (goldGramsToUse.gt(0)) {
        await goldLedgerService.postRedemptionDebit({
          userId,
          orderId: order.id,
          gramsDelta: goldGramsToUse,
          amountPaise: Math.min(goldAppliedPaise, totals.totalPaise),
          goldRatePerGramPaise: rate.ratePerGramPaise,
          tx,
        });
      }

      let paymentTransactionId: string | null = null;

      if (requiresOnlinePayment) {
        const user = await prisma.user.findUniqueOrThrow({
          where: { id: userId },
        });

        const providerOrder = await paymentProviderClient.createOrder({
          amountPaise: paymentAmountPaise,
          orderId: order.id,
          customerId: userId,
          customerPhone: user.phone,
        });

        const paymentTx = await tx.paymentTransaction.create({
          data: {
            userId,
            type: "order_payment",
            status: env.PAYMENT_PROVIDER_MODE === "mock" ? "pending" : "created",
            amountPaise: paymentAmountPaise,
            providerOrderId: providerOrder.providerOrderId,
            providerSessionId: providerOrder.paymentSessionId,
            provider: env.PAYMENT_PROVIDER ?? "razorpay",
            idempotencyKey: `order_payment:${order.id}`,
          },
        });

        paymentTransactionId = paymentTx.id;
        paymentSessionId = providerOrder.paymentSessionId;
        paymentUrl =
          env.PAYMENT_PROVIDER_MODE === "mock"
            ? `mock://pay/${paymentTx.id}`
            : null;
        razorpayOrderId = providerOrder.providerOrderId;

        await tx.order.update({
          where: { id: order.id },
          data: { paymentTransactionId },
        });
      }

      const fullOrder = await tx.order.findUniqueOrThrow({
        where: { id: order.id },
        include: { items: true },
      });

      return { order: fullOrder, paymentTransactionId };
    });

    if (
      result.paymentTransactionId &&
      env.PAYMENT_PROVIDER_MODE === "mock" &&
      paymentAmountPaise > 0
    ) {
      await applyPaymentCapture({
        paymentTransactionId: result.paymentTransactionId,
      });
      const refreshed = await prisma.order.findUniqueOrThrow({
        where: { id: result.order.id },
        include: { items: true },
      });
      result.order = refreshed;
    }

    if (totals.totalPaise >= SAR_THRESHOLD_PAISE) {
      await prisma.sarReview.upsert({
        where: { orderId: result.order.id },
        create: {
          orderId: result.order.id,
          status: "pending",
        },
        update: {},
      });
    }

    if (goldGramsToUse.gt(0)) {
      await goldBalanceService.refreshSnapshot(userId, "redemption");
    }

    await prisma.cartItem.deleteMany({
      where: {
        userId,
        productId: { in: lines.map((line) => line.product.id) },
      },
    });

    const finalPaymentAmount =
      result.order.status === "confirmed" ? 0 : paymentAmountPaise;

    if (result.order.status === "confirmed" && !result.paymentTransactionId) {
      await notifyOrderConfirmed({
        userId,
        orderId: result.order.id,
        orderNumber: result.order.orderNumber,
        totalDisplay: formatPaise(result.order.totalPaise),
      });
    }

    return {
      order: mapOrderToDto(result.order),
      payment_required: finalPaymentAmount > 0,
      payment_amount_paise: finalPaymentAmount,
      payment_session_id: paymentSessionId,
      payment_url: paymentUrl,
      razorpay_order_id: razorpayOrderId,
      razorpay_key_id:
        finalPaymentAmount > 0 ? (env.RAZORPAY_KEY_ID ?? null) : null,
      cashfree_order_id: razorpayOrderId,
      cashfree_app_id: finalPaymentAmount > 0 ? (env.CASHFREE_APP_ID ?? null) : null,
      aura_mc_waiver_applied: totals.makingChargeWaiverPaise > 0,
      making_charge_waiver_paise: totals.makingChargeWaiverPaise,
      making_charge_waiver_display:
        totals.makingChargeWaiverPaise > 0
          ? formatPaise(totals.makingChargeWaiverPaise)
          : null,
    };
  }

  async cancel(userId: string, orderId: string, reason: string) {
    const order = await prisma.order.findFirst({
      where: { id: orderId, userId },
      include: { items: true },
    });

    if (!order) {
      throw new AppError(404, "NOT_FOUND", "Order does not exist");
    }

    if (
      !CANCELLABLE_ORDER_STATUSES.includes(
        order.status as (typeof CANCELLABLE_ORDER_STATUSES)[number],
      )
    ) {
      throw new AppError(409, "CONFLICT", "Order cannot be cancelled");
    }

    const refundInitiated = await processOrderRefund(order.id, reason);

    const refreshed = await prisma.order.findUniqueOrThrow({
      where: { id: order.id },
      include: { items: true },
    });

    return {
      order: mapOrderToDto(refreshed),
      refund_initiated: refundInitiated,
    };
  }

  private async linesFromResolvedQuote(resolved: ResolvedQuote): Promise<PricedLine[]> {
    const lines: PricedLine[] = [];

    for (const snapshot of resolved.lines) {
      const product = await prisma.product.findFirst({
        where: {
          id: snapshot.product_id,
          isPublished: true,
          deletedAt: null,
        },
        include: productInclude(),
      });

      if (!product) {
        throw new AppError(404, "NOT_FOUND", "Product does not exist");
      }

      const productDto = await mapProductToDto(product);

      lines.push({
        product,
        quantity: snapshot.quantity,
        price: snapshot.price,
        productDto,
      });
    }

    return lines;
  }

  async updateFulfillmentStatus(
    orderId: string,
    status: "shipped" | "delivered",
  ) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
    });

    if (!order) {
      throw new AppError(404, "NOT_FOUND", "Order does not exist");
    }

    const now = new Date();
    const updated = await prisma.order.update({
      where: { id: orderId },
      data: {
        status,
        ...(status === "shipped" ? { shippedAt: now } : {}),
        ...(status === "delivered" ? { deliveredAt: now } : {}),
      },
      include: { items: true },
    });

    if (status === "shipped") {
      await notifyOrderShipped({
        userId: updated.userId,
        orderId: updated.id,
        orderNumber: updated.orderNumber,
      });
    } else {
      await notifyOrderDelivered({
        userId: updated.userId,
        orderId: updated.id,
        orderNumber: updated.orderNumber,
      });
    }

    return { order: mapOrderToDto(updated) };
  }
}

export const ordersService = new OrdersService();
