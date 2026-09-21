import type { Prisma } from "@prisma/client";
import type { AuraProductPriceDto } from "../goals/aura.mc_waiver.service";

export interface QuoteItemInput {
  product_id: string;
  quantity: number;
}

export interface QuoteLineSnapshot {
  product_id: string;
  quantity: number;
  unit_price_paise: number;
  gold_value_paise: number;
  making_charge_paise: number;
  wastage_paise: number;
  stone_value_paise: number;
  gst_paise: number;
  mc_waiver_paise: number;
  gold_rate_paise: number;
  product_snapshot: {
    id: string;
    name: string;
    sku: string;
    primary_image: string | null;
  };
  price: AuraProductPriceDto;
}

export interface QuoteTotals {
  totalPaise: number;
  goldValuePaise: number;
  makingChargesPaise: number;
  wastagePaise: number;
  stoneValuePaise: number;
  gstPaise: number;
  makingChargeWaiverPaise: number;
}

export interface ResolvedQuote {
  quoteId: string;
  validUntil: Date;
  serverTimeAtIssue: Date;
  goldRateAtQuotePaise: number;
  auraPlanGoalId: string | null;
  lines: QuoteLineSnapshot[];
  totals: QuoteTotals;
}

export function quoteLinesToJson(
  lines: QuoteLineSnapshot[],
): Prisma.InputJsonValue {
  return lines as unknown as Prisma.InputJsonValue;
}

export function parseQuoteLines(value: Prisma.JsonValue): QuoteLineSnapshot[] {
  return value as unknown as QuoteLineSnapshot[];
}
