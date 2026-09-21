import type { Prisma } from "@prisma/client";
import { prisma } from "../../db/prisma";
import {
  ORDER_CREATE_LATENCY_TOLERANCE_MS,
  PRICE_VALIDITY_MS,
} from "../../config/price.constants";
import { GOAL_ACCUMULATION_PURITY } from "../../config/goals.constants";
import { AppError } from "../../middleware/error.middleware";
import { formatPaise } from "../../utils/money";
import {
  calculateProductPriceWithAuraMcWaiver,
  findActiveAuraMcWaiverGoal,
  type AuraProductPriceDto,
} from "../goals/aura.mc_waiver.service";
import { getAvailableStock } from "../inventory/inventory.service";
import { goldRatesService } from "../gold_rates/gold_rates.service";
import { calculateProductPrice } from "../products/price";
import {
  mapProductToDto,
  productInclude,
  type ProductWithRelations,
} from "../products/product.mapper";
import { mapQuoteToDto } from "./quote.mapper";
import type {
  QuoteItemInput,
  QuoteLineSnapshot,
  QuoteTotals,
  ResolvedQuote,
} from "./quote.types";
import { parseQuoteLines, quoteLinesToJson } from "./quote.types";

interface PricedQuoteLine {
  product: ProductWithRelations;
  quantity: number;
  price: AuraProductPriceDto;
  productDto: Awaited<ReturnType<typeof mapProductToDto>>;
}

function aggregateQuoteTotals(lines: QuoteLineSnapshot[]): QuoteTotals {
  return lines.reduce(
    (totals, line) => ({
      totalPaise: totals.totalPaise + line.unit_price_paise * line.quantity,
      goldValuePaise:
        totals.goldValuePaise + line.gold_value_paise * line.quantity,
      makingChargesPaise:
        totals.makingChargesPaise +
        line.making_charge_paise * line.quantity,
      wastagePaise: totals.wastagePaise + line.wastage_paise * line.quantity,
      stoneValuePaise:
        totals.stoneValuePaise + line.stone_value_paise * line.quantity,
      gstPaise: totals.gstPaise + line.gst_paise * line.quantity,
      makingChargeWaiverPaise:
        totals.makingChargeWaiverPaise + line.mc_waiver_paise * line.quantity,
    }),
    {
      totalPaise: 0,
      goldValuePaise: 0,
      makingChargesPaise: 0,
      wastagePaise: 0,
      stoneValuePaise: 0,
      gstPaise: 0,
      makingChargeWaiverPaise: 0,
    },
  );
}

function normalizeItems(items: QuoteItemInput[]): QuoteItemInput[] {
  return [...items]
    .map((item) => ({
      product_id: item.product_id,
      quantity: item.quantity,
    }))
    .sort((a, b) => a.product_id.localeCompare(b.product_id));
}

function itemsFingerprint(items: QuoteItemInput[]): string {
  return normalizeItems(items)
    .map((item) => `${item.product_id}:${item.quantity}`)
    .join("|");
}

export class QuoteService {
  async invalidateActiveQuotes(userId: string): Promise<void> {
    await prisma.priceQuote.updateMany({
      where: { userId, status: "active" },
      data: { status: "superseded" },
    });
  }

  async createFromCart(userId: string) {
    const cartItems = await prisma.cartItem.findMany({
      where: { userId },
      orderBy: { addedAt: "asc" },
    });

    if (cartItems.length === 0) {
      throw new AppError(422, "UNPROCESSABLE", "Cart is empty");
    }

    return this.createQuote(
      userId,
      cartItems.map((item) => ({
        product_id: item.productId,
        quantity: item.quantity,
      })),
    );
  }

  async createQuote(userId: string, items: QuoteItemInput[]) {
    const serverTime = new Date();
    await this.invalidateActiveQuotes(userId);

    const priced = await this.priceItems(userId, items, false);
    const lines = this.toLineSnapshots(priced.lines);
    const totals = aggregateQuoteTotals(lines);
    const validUntil = new Date(serverTime.getTime() + PRICE_VALIDITY_MS);

    const quote = await prisma.priceQuote.create({
      data: {
        userId,
        status: "active",
        validUntil,
        serverTimeAtIssue: serverTime,
        totalPaise: totals.totalPaise,
        goldValuePaise: totals.goldValuePaise,
        makingChargesPaise: totals.makingChargesPaise,
        wastagePaise: totals.wastagePaise,
        stoneValuePaise: totals.stoneValuePaise,
        gstPaise: totals.gstPaise,
        makingChargeWaiverPaise: totals.makingChargeWaiverPaise,
        auraPlanGoalId: priced.auraPlanGoalId,
        goldRateAtQuotePaise: priced.goldRateAtQuotePaise,
        linesJson: quoteLinesToJson(lines),
      },
    });

    return mapQuoteToDto(quote, serverTime);
  }

  async getLatestActiveQuote(userId: string) {
    const quote = await prisma.priceQuote.findFirst({
      where: { userId, status: "active" },
      orderBy: { createdAt: "desc" },
    });

    if (!quote) {
      return null;
    }

    if (quote.validUntil <= new Date()) {
      await prisma.priceQuote.update({
        where: { id: quote.id },
        data: { status: "expired" },
      });
      return null;
    }

    return mapQuoteToDto(quote);
  }

  async resolveForOrder(
    userId: string,
    quoteId: string,
    items: QuoteItemInput[],
  ): Promise<ResolvedQuote> {
    const serverTime = new Date();
    const quote = await prisma.priceQuote.findFirst({
      where: { id: quoteId, userId },
    });

    if (!quote) {
      throw new AppError(404, "NOT_FOUND", "Price quote does not exist");
    }

    const storedLines = parseQuoteLines(quote.linesJson);
    const requestFingerprint = itemsFingerprint(items);
    const quoteFingerprint = itemsFingerprint(
      storedLines.map((line) => ({
        product_id: line.product_id,
        quantity: line.quantity,
      })),
    );

    if (requestFingerprint !== quoteFingerprint) {
      throw new AppError(409, "PRICE_CHANGED", "Cart contents changed", {
        quote_id: quote.id,
      });
    }

    const expired =
      quote.validUntil.getTime() + ORDER_CREATE_LATENCY_TOLERANCE_MS <
      serverTime.getTime();

    if (quote.status !== "active" || expired) {
      const freshQuote = await this.createQuote(userId, items);
      throw new AppError(409, "PRICE_EXPIRED", "Price quote has expired", {
        quote_id: quote.id,
        price_valid_until: quote.validUntil.toISOString(),
        fresh_quote: freshQuote,
      });
    }

    return {
      quoteId: quote.id,
      validUntil: quote.validUntil,
      serverTimeAtIssue: quote.serverTimeAtIssue,
      goldRateAtQuotePaise: quote.goldRateAtQuotePaise,
      auraPlanGoalId: quote.auraPlanGoalId,
      lines: storedLines,
      totals: {
        totalPaise: quote.totalPaise,
        goldValuePaise: quote.goldValuePaise,
        makingChargesPaise: quote.makingChargesPaise,
        wastagePaise: quote.wastagePaise,
        stoneValuePaise: quote.stoneValuePaise,
        gstPaise: quote.gstPaise,
        makingChargeWaiverPaise: quote.makingChargeWaiverPaise,
      },
    };
  }

  async markConsumed(
    quoteId: string,
    orderId: string,
    tx: Prisma.TransactionClient,
  ) {
    await tx.priceQuote.updateMany({
      where: { id: quoteId, status: "active" },
      data: { status: "consumed", consumedOrderId: orderId },
    });
  }

  private toLineSnapshots(lines: PricedQuoteLine[]): QuoteLineSnapshot[] {
    return lines.map((line) => ({
      product_id: line.product.id,
      quantity: line.quantity,
      unit_price_paise: line.price.total_paise,
      gold_value_paise: line.price.gold_value_paise,
      making_charge_paise: line.price.making_charge_paise,
      wastage_paise: line.price.wastage_paise,
      stone_value_paise: line.product.stoneValuePaise ?? 0,
      gst_paise: line.price.gst_paise,
      mc_waiver_paise: line.price.mc_waiver_paise ?? 0,
      gold_rate_paise: line.price.rate_used_paise,
      product_snapshot: {
        id: line.product.id,
        name: line.product.name,
        sku: line.product.sku,
        primary_image: line.productDto.primary_image,
      },
      price: line.price,
    }));
  }

  private async priceItems(
    userId: string,
    items: QuoteItemInput[],
    usesGoldIntent: boolean,
  ) {
    const auraMcWaiverGoal = usesGoldIntent
      ? await findActiveAuraMcWaiverGoal(userId)
      : null;
    const lines: PricedQuoteLine[] = [];

    for (const item of normalizeItems(items)) {
      const product = await prisma.product.findFirst({
        where: {
          id: item.product_id,
          isPublished: true,
          deletedAt: null,
        },
        include: productInclude(),
      });

      if (!product) {
        throw new AppError(404, "NOT_FOUND", "Product does not exist");
      }

      const available = await getAvailableStock(
        product.id,
        product.stockQuantity,
      );

      if (available < item.quantity) {
        throw new AppError(400, "OUT_OF_STOCK", "Product is out of stock");
      }

      const currentRate = await goldRatesService.currentRateForPurity(
        product.purity,
      );
      const priceInput = {
        weightGrams: product.weightGrams,
        ratePerGramPaise: currentRate.ratePerGramPaise,
        makingChargePct: product.makingChargePct,
        wastagePct: product.wastagePct,
        stoneValuePaise: product.stoneValuePaise,
        gstPct: product.gstPct,
        rateUpdatedAt: currentRate.effectiveFrom,
      };
      const price = auraMcWaiverGoal
        ? calculateProductPriceWithAuraMcWaiver(priceInput)
        : {
            ...calculateProductPrice(priceInput),
            mc_waiver_paise: 0,
            mc_waiver_display: formatPaise(0),
            mc_waiver_applied: false,
          };
      const productDto = await mapProductToDto(product);

      lines.push({
        product,
        quantity: item.quantity,
        price,
        productDto,
      });
    }

    const accumulationRate = await goldRatesService.currentRateForPurity(
      GOAL_ACCUMULATION_PURITY,
    );

    return {
      lines,
      auraPlanGoalId: auraMcWaiverGoal?.id ?? null,
      goldRateAtQuotePaise: accumulationRate.ratePerGramPaise,
    };
  }
}

export const quoteService = new QuoteService();
