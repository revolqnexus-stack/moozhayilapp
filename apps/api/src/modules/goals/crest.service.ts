import type { Goal, SchemeType } from "@prisma/client";
import Decimal from "decimal.js";
import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import { calculateGramsFromPaise } from "../../utils/gold";
import {
  CREST_ADVANCE_STEP_PAISE,
  CREST_DURATION_MONTHS,
  CREST_MIN_ADVANCE_PAISE,
  CREST_SCHEME_TYPE,
} from "../../config/crest.constants";
import { GOLDEN_WISH_MC_WAIVER_PCT } from "../../config/golden_wish.constants";
import type { CreateGoalInput } from "./goals.schema";

export function isCrestScheme(
  schemeType: SchemeType | null | undefined,
): boolean {
  return schemeType === CREST_SCHEME_TYPE;
}

/** Grams posted for a completed contribution (CREST uses locked targetGrams when set). */
export function resolveContributionGramsCredited(input: {
  schemeType: SchemeType | null | undefined;
  targetGrams: Decimal.Value | null | undefined;
  amountPaise: number;
  goldRatePerGramPaise: number;
}): Decimal {
  let grams = calculateGramsFromPaise(
    input.amountPaise,
    input.goldRatePerGramPaise,
  );
  if (isCrestScheme(input.schemeType) && input.targetGrams != null) {
    const locked = new Decimal(input.targetGrams);
    if (locked.gt(0)) {
      grams = locked;
    }
  }
  return grams;
}

export function validateCrestCreateInput(input: CreateGoalInput): void {
  if (input.duration_months !== CREST_DURATION_MONTHS) {
    throw new AppError(
      422,
      "UNPROCESSABLE",
      "Crest is a single advance payment plan",
    );
  }

  if (input.monthly_amount_paise < CREST_MIN_ADVANCE_PAISE) {
    throw new AppError(
      422,
      "UNPROCESSABLE",
      "Minimum Crest advance is ₹500",
    );
  }

  if (input.monthly_amount_paise % CREST_ADVANCE_STEP_PAISE !== 0) {
    throw new AppError(
      422,
      "UNPROCESSABLE",
      "Crest advance must be in multiples of ₹500",
    );
  }
}

export async function countCompletedCrestPayments(goalId: string): Promise<number> {
  return prisma.contribution.count({
    where: {
      goalId,
      status: "completed",
      type: { in: ["manual", "autopay"] },
    },
  });
}

export function validateCrestContributionAmount(
  goal: Goal,
  amountPaise: number,
  completedPayments: number,
): void {
  if (completedPayments >= 1) {
    throw new AppError(
      422,
      "UNPROCESSABLE",
      "Crest advance is already paid — gold weight is locked",
    );
  }

  if (amountPaise !== goal.monthlyAmountPaise) {
    throw new AppError(
      422,
      "UNPROCESSABLE",
      "Crest advance amount is locked at enrollment",
    );
  }
}

export function mapCrestPlanFields(goal: Goal, completedPayments: number) {
  if (!isCrestScheme(goal.schemeType)) {
    return {};
  }

  return {
    advance_paid: completedPayments >= 1,
    mc_waiver_max_pct: GOLDEN_WISH_MC_WAIVER_PCT,
    mc_waiver_active: completedPayments >= 1,
  };
}
