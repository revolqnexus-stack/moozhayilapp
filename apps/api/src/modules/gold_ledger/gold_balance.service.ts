import { prisma } from "../../db/prisma";
import { goldRatesService } from "../gold_rates/gold_rates.service";
import {
  decimalString,
  formatGoldGrams,
  calculateValuePaiseFromGrams,
} from "../../utils/gold";
import { formatPaise } from "../../utils/money";
import { goldLedgerService } from "./gold_ledger.service";
import { GOAL_ACCUMULATION_PURITY } from "../../config/goals.constants";
import { apiPurity } from "../gold_rates/gold_rates.service";
import {
  GOLD_RATE_STALE_AFTER_SECONDS,
  isGoldRateStale,
} from "../../config/gold_rates.constants";

export class GoldBalanceService {
  async getBalance(userId: string) {
    const rate = await goldRatesService.currentRateForPurity(GOAL_ACCUMULATION_PURITY);
    const totalGrams = await goldLedgerService.getPostedBalanceGrams(userId);
    const totalValuePaise = goldLedgerService.balanceValuePaise(
      totalGrams,
      rate.ratePerGramPaise,
    );

    return {
      total_grams: decimalString(totalGrams),
      total_grams_display: formatGoldGrams(totalGrams),
      total_value_paise: totalValuePaise,
      total_value_display: formatPaise(totalValuePaise),
      rate_used: {
        purity: apiPurity(rate.purity),
        rate_paise: rate.ratePerGramPaise,
        rate_display: `${formatPaise(rate.ratePerGramPaise)}/g`,
        updated_at: rate.effectiveFrom.toISOString(),
        is_stale: isGoldRateStale(rate.effectiveFrom),
        stale_after_seconds: GOLD_RATE_STALE_AFTER_SECONDS,
      },
    };
  }

  async refreshSnapshot(userId: string, reason: string) {
    // Snapshots are audit/cache rows only — never read for balance or progress.
    const rate = await goldRatesService.currentRateForPurity(GOAL_ACCUMULATION_PURITY);
    const totalGrams = await goldLedgerService.getPostedBalanceGrams(userId);
    const totalValuePaise = calculateValuePaiseFromGrams(
      totalGrams,
      rate.ratePerGramPaise,
    );
    const now = new Date();

    return prisma.goldBalanceSnapshot.create({
      data: {
        userId,
        totalGrams: totalGrams.toFixed(4),
        totalValuePaise,
        goldRateUsedPaise: rate.ratePerGramPaise,
        snapshotAt: now,
        reason,
      },
    });
  }

  async latestSnapshot(userId: string) {
    return prisma.goldBalanceSnapshot.findFirst({
      where: { userId },
      orderBy: { snapshotAt: "desc" },
    });
  }
}

export const goldBalanceService = new GoldBalanceService();
