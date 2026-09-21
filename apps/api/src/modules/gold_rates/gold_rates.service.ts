import type { Purity } from "@prisma/client";
import { prisma } from "../../db/prisma";
import {
  GOLD_RATE_STALE_AFTER_SECONDS,
  isGoldRateStale,
} from "../../config/gold_rates.constants";
import { getJsonCache, setJsonCache } from "../../utils/cache";
import { formatPaise } from "../../utils/money";

const purityValues: Purity[] = ["k14", "k18", "k22", "k24"];

export function apiPurity(value: Purity): "14k" | "18k" | "22k" | "24k" {
  return `${value.replace("k", "")}k` as "14k" | "18k" | "22k" | "24k";
}

export function dbPurity(value: string): Purity {
  return `k${value.replace("k", "")}` as Purity;
}

export class GoldRatesService {
  async currentRates() {
    const cacheKey = "gold-rates:current";
    const cached = await getJsonCache<Record<string, unknown>>(cacheKey);
    if (cached) {
      return cached;
    }

    const rates = await prisma.goldRateHistory.findMany({
      where: { purity: { in: purityValues }, effectiveTo: null },
      orderBy: { effectiveFrom: "desc" },
    });

    const latestByPurity = new Map<Purity, (typeof rates)[number]>();
    for (const rate of rates) {
      if (!latestByPurity.has(rate.purity)) {
        latestByPurity.set(rate.purity, rate);
      }
    }

    const response = {
      rates: Object.fromEntries(
        purityValues
          .map((purity) => latestByPurity.get(purity))
          .filter((rate) => rate !== undefined)
          .map((rate) => [
            apiPurity(rate.purity),
            {
              rate_per_gram_paise: rate.ratePerGramPaise,
              rate_display: `${formatPaise(rate.ratePerGramPaise)}/g`,
              updated_at: rate.effectiveFrom.toISOString(),
              change_pct_today: 0,
              change_pct_30d: 0,
              is_stale: isGoldRateStale(rate.effectiveFrom),
              stale_after_seconds: GOLD_RATE_STALE_AFTER_SECONDS,
            },
          ]),
      ),
    };

    await setJsonCache(cacheKey, response, 60);
    return response;
  }

  async currentRateForPurity(purity: Purity) {
    const rate = await prisma.goldRateHistory.findFirst({
      where: { purity, effectiveTo: null },
      orderBy: { effectiveFrom: "desc" },
    });

    if (!rate) {
      throw new Error(`Missing active gold rate for ${apiPurity(purity)}`);
    }

    return rate;
  }

  async history(input: { purity: Purity; days: number }) {
    const since = new Date(Date.now() - input.days * 24 * 60 * 60 * 1000);
    const history = await prisma.goldRateHistory.findMany({
      where: {
        purity: input.purity,
        effectiveFrom: { gte: since },
      },
      orderBy: { effectiveFrom: "asc" },
    });

    return {
      purity: apiPurity(input.purity),
      history: history.map((rate) => ({
        date: rate.effectiveFrom.toISOString().slice(0, 10),
        rate_paise: rate.ratePerGramPaise,
      })),
    };
  }
}

export const goldRatesService = new GoldRatesService();
