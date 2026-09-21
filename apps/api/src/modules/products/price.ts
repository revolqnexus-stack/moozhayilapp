import Decimal from "decimal.js";
import { PRICE_VALIDITY_MS } from "../../config/price.constants";
import { formatPaise } from "../../utils/money";

export interface ProductPriceInput {
  weightGrams: Decimal.Value;
  ratePerGramPaise: number;
  makingChargePct: Decimal.Value;
  wastagePct: Decimal.Value;
  stoneValuePaise: number;
  gstPct: Decimal.Value;
  rateUpdatedAt: Date;
  generatedAt?: Date;
}

export interface ProductPriceDto {
  total_paise: number;
  total_display: string;
  gold_value_paise: number;
  gold_value_display: string;
  making_charge_paise: number;
  making_charge_display: string;
  wastage_paise: number;
  gst_paise: number;
  gst_display: string;
  rate_used_paise: number;
  rate_display: string;
  rate_updated_at: string;
  price_valid_until: string;
}

function toPaise(value: Decimal): number {
  return value.toDecimalPlaces(0, Decimal.ROUND_HALF_UP).toNumber();
}

export function calculateProductPrice(input: ProductPriceInput): ProductPriceDto {
  const generatedAt = input.generatedAt ?? new Date();
  const goldValue = new Decimal(input.weightGrams).mul(input.ratePerGramPaise);
  const goldValuePaise = toPaise(goldValue);
  const makingChargePaise = toPaise(
    new Decimal(goldValuePaise).mul(input.makingChargePct).div(100),
  );
  const wastagePaise = toPaise(
    new Decimal(goldValuePaise).mul(input.wastagePct).div(100),
  );
  const basePricePaise =
    goldValuePaise + makingChargePaise + wastagePaise + input.stoneValuePaise;
  const gstPaise = toPaise(new Decimal(basePricePaise).mul(input.gstPct).div(100));
  const totalPaise = basePricePaise + gstPaise;
  const priceValidUntil = new Date(generatedAt.getTime() + PRICE_VALIDITY_MS);

  return {
    total_paise: totalPaise,
    total_display: formatPaise(totalPaise),
    gold_value_paise: goldValuePaise,
    gold_value_display: formatPaise(goldValuePaise),
    making_charge_paise: makingChargePaise,
    making_charge_display: formatPaise(makingChargePaise),
    wastage_paise: wastagePaise,
    gst_paise: gstPaise,
    gst_display: formatPaise(gstPaise),
    rate_used_paise: input.ratePerGramPaise,
    rate_display: `${formatPaise(input.ratePerGramPaise)}/g`,
    rate_updated_at: input.rateUpdatedAt.toISOString(),
    price_valid_until: priceValidUntil.toISOString(),
  };
}
