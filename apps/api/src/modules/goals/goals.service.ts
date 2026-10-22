import Decimal from "decimal.js";
import type { GoalStatus, KycStatus } from "@prisma/client";
import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import {
  BASIC_MAX_MONTHLY_CONTRIBUTION_PAISE,
  ENHANCED_MAX_MONTHLY_CONTRIBUTION_PAISE,
  GOAL_ACCUMULATION_PURITY,
  MAX_ACTIVE_GOALS,
} from "../../config/goals.constants";
import { DEFAULT_SCHEME_TYPE } from "../../config/schemes.constants";
import {
  countCompletedAuraInstallments,
  isAuraScheme,
  validateAuraCreateInput,
} from "./aura.service";
import {
  countCompletedCrestPayments,
  isCrestScheme,
  validateCrestCreateInput,
} from "./crest.service";
import {
  isDhanamScheme,
  validateDhanamCreateInput,
} from "./dhanam.service";
import {
  isGoldNidhiScheme,
  validateGoldNidhiCreateInput,
} from "./gold_nidhi.service";
import {
  checkGoalCreationGate,
} from "../../utils/kyc_gates";
import { withIdempotency } from "../../utils/idempotency";
import { toDateOnly, formatDateOnly } from "../../utils/dates";
import { decimalString, calculateGramsFromPaise } from "../../utils/gold";
import { goldRatesService } from "../gold_rates/gold_rates.service";
import { goldLedgerService } from "../gold_ledger/gold_ledger.service";
import { calculateProductPrice } from "../products/price";
import {
  mapProductToDto,
  productInclude,
} from "../products/product.mapper";
import { contributionsService } from "../contributions/contributions.service";
import { mapGoalToDto } from "./goal.mapper";
import type {
  ContributeInput,
  CreateGoalInput,
  ListGoalsQuery,
  PatchGoalInput,
} from "./goals.schema";

const ACTIVE_GOAL_STATUSES: GoalStatus[] = [
  "active",
  "contribution_due",
  "paused",
];

function monthlyLimitForKyc(kycStatus: KycStatus): number {
  return kycStatus === "enhanced_verified"
    ? ENHANCED_MAX_MONTHLY_CONTRIBUTION_PAISE
    : BASIC_MAX_MONTHLY_CONTRIBUTION_PAISE;
}

export class GoalsService {
  async countActiveGoals(userId: string): Promise<number> {
    return prisma.goal.count({
      where: {
        userId,
        deletedAt: null,
        status: { in: ACTIVE_GOAL_STATUSES },
      },
    });
  }

  async list(userId: string, query: ListGoalsQuery) {
    const statusFilter =
      query.status === "all"
        ? undefined
        : query.status === "active"
          ? { in: ACTIVE_GOAL_STATUSES }
          : query.status;

    const goals = await prisma.goal.findMany({
      where: {
        userId,
        deletedAt: null,
        ...(statusFilter ? { status: statusFilter } : {}),
      },
      include: {
        targetProduct: {
          include: {
            images: { orderBy: [{ sortOrder: "asc" }] },
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    const rate = await goldRatesService.currentRateForPurity(
      GOAL_ACCUMULATION_PURITY,
    );
    const totalGrams = await goldLedgerService.getPostedBalanceGrams(userId);
    const totalValuePaise = goldLedgerService.balanceValuePaise(
      totalGrams,
      rate.ratePerGramPaise,
    );

    const mapped = await Promise.all(
      goals.map(async (goal) => {
        const currentGrams = await goldLedgerService.getGoalCreditedGrams(
          goal.id,
        );
        const completedInstallments = isAuraScheme(goal.schemeType)
          ? await countCompletedAuraInstallments(goal.id)
          : isCrestScheme(goal.schemeType)
            ? await countCompletedCrestPayments(goal.id)
            : 0;
        return mapGoalToDto(
          goal,
          currentGrams,
          rate.ratePerGramPaise,
          completedInstallments,
        );
      }),
    );

    const activeGoals = goals.filter((goal) =>
      ACTIVE_GOAL_STATUSES.includes(goal.status),
    );

    return {
      goals: mapped,
      summary: {
        total_grams: decimalString(totalGrams),
        total_grams_display: `${new Decimal(totalGrams).toDecimalPlaces(1, Decimal.ROUND_DOWN).toFixed(1)}g`,
        total_value_paise: totalValuePaise,
        total_value_display: new Intl.NumberFormat("en-IN", {
          style: "currency",
          currency: "INR",
          maximumFractionDigits: 0,
        }).format(totalValuePaise / 100),
        active_count: activeGoals.length,
        monthly_total_paise: activeGoals.reduce(
          (sum, goal) => sum + goal.monthlyAmountPaise,
          0,
        ),
        monthly_total_display: `${new Intl.NumberFormat("en-IN", {
          style: "currency",
          currency: "INR",
          maximumFractionDigits: 0,
        }).format(
          activeGoals.reduce(
            (sum, goal) => sum + goal.monthlyAmountPaise,
            0,
          ) / 100,
        )}/mo`,
      },
    };
  }

  async create(
    userId: string,
    kycStatus: KycStatus,
    input: CreateGoalInput,
    idempotencyKey: string,
  ) {
    return withIdempotency({
      userId,
      scope: "goals.create",
      key: idempotencyKey,
      requestBody: input,
      resourceType: "goal",
      handler: async () => this.createGoal(userId, kycStatus, input),
    });
  }

  async createForAdmin(
    userId: string,
    input: CreateGoalInput,
    idempotencyKey: string,
  ) {
    const user = await prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
      select: { id: true, kycStatus: true },
    });

    if (!user) {
      throw new AppError(404, "NOT_FOUND", "User does not exist");
    }

    return withIdempotency({
      userId,
      scope: "admin.goals.create",
      key: idempotencyKey,
      requestBody: input,
      resourceType: "goal",
      handler: async () =>
        this.createGoal(userId, user.kycStatus, input, {
          skipKycGate: true,
          skipMonthlyKycLimit: true,
        }),
    });
  }

  private async createGoal(
    userId: string,
    kycStatus: KycStatus,
    input: CreateGoalInput,
    options?: { skipKycGate?: boolean; skipMonthlyKycLimit?: boolean },
  ) {
    if (!options?.skipKycGate) {
      const gate = checkGoalCreationGate(kycStatus);
      if (!gate.allowed) {
        throw new AppError(403, gate.code ?? "KYC_REQUIRED", gate.message ?? "");
      }
    }

    const monthlyLimit = monthlyLimitForKyc(kycStatus);
    const schemeType = input.scheme_type ?? DEFAULT_SCHEME_TYPE;

    if (isAuraScheme(schemeType)) {
      validateAuraCreateInput(input);
    } else if (isCrestScheme(schemeType)) {
      validateCrestCreateInput(input);
    } else if (isDhanamScheme(schemeType)) {
      validateDhanamCreateInput(input);
    } else if (isGoldNidhiScheme(schemeType)) {
      validateGoldNidhiCreateInput(input);
    }

    const skipMonthlyLimit =
      isCrestScheme(schemeType) || isDhanamScheme(schemeType);

    if (
      !options?.skipMonthlyKycLimit &&
      !skipMonthlyLimit &&
      input.monthly_amount_paise > monthlyLimit
    ) {
      throw new AppError(
        422,
        "UNPROCESSABLE",
        kycStatus === "enhanced_verified"
          ? "Monthly contribution exceeds enhanced KYC limit"
          : "Monthly contribution exceeds basic KYC limit of ₹50,000",
      );
    }

    const activeCount = await this.countActiveGoals(userId);
    if (activeCount >= MAX_ACTIVE_GOALS) {
      throw new AppError(
        422,
        "UNPROCESSABLE",
        "You can have at most 5 active goals",
      );
    }

    if (input.payment_method_id) {
      const paymentMethod = await prisma.paymentMethod.findFirst({
        where: {
          id: input.payment_method_id,
          userId,
          deletedAt: null,
        },
      });

      if (!paymentMethod) {
        throw new AppError(404, "NOT_FOUND", "Payment method does not exist");
      }
    }

    let targetAmountPaise = input.target_amount_paise ?? null;
    let targetGrams: string | null = null;
    let targetProductId: string | null = input.target_product_id ?? null;

    if (input.target_product_id) {
      const product = await prisma.product.findFirst({
        where: {
          id: input.target_product_id,
          isPublished: true,
          deletedAt: null,
        },
      });

      if (!product) {
        throw new AppError(404, "NOT_FOUND", "Target product does not exist");
      }

      const rate = await goldRatesService.currentRateForPurity(product.purity);
      const price = calculateProductPrice({
        weightGrams: product.weightGrams,
        ratePerGramPaise: rate.ratePerGramPaise,
        makingChargePct: product.makingChargePct,
        wastagePct: product.wastagePct,
        stoneValuePaise: product.stoneValuePaise,
        gstPct: product.gstPct,
        rateUpdatedAt: rate.effectiveFrom,
      });

      targetAmountPaise = price.total_paise;
      targetGrams = decimalString(product.weightGrams);
      targetProductId = product.id;
    }

    const startDate = toDateOnly(new Date(`${input.start_date}T00:00:00.000Z`));

    const rate = await goldRatesService.currentRateForPurity(
      GOAL_ACCUMULATION_PURITY,
    );

    const bookingRatePaisePerGram =
      isDhanamScheme(schemeType) || isCrestScheme(schemeType)
        ? rate.ratePerGramPaise
        : null;

    if (isCrestScheme(schemeType) && !targetGrams) {
      targetGrams = calculateGramsFromPaise(
        input.monthly_amount_paise,
        rate.ratePerGramPaise,
      ).toFixed(4);
    }

    const goal = await prisma.goal.create({
      data: {
        userId,
        name: input.name,
        schemeType: input.scheme_type ?? DEFAULT_SCHEME_TYPE,
        goalType: input.goal_type,
        targetProductId,
        targetAmountPaise,
        targetGrams,
        monthlyAmountPaise: input.monthly_amount_paise,
        durationMonths: input.duration_months,
        startDate,
        nextContributionDate: startDate,
        paymentMethodId: input.payment_method_id ?? null,
        bonusEligible: !isAuraScheme(schemeType),
        bookingRatePaisePerGram,
      },
      include: {
        targetProduct: {
          include: {
            images: { orderBy: [{ sortOrder: "asc" }] },
          },
        },
      },
    });

    return {
      goal: mapGoalToDto(goal, new Decimal(0), rate.ratePerGramPaise, 0),
      first_contribution_scheduled: formatDateOnly(startDate),
    };
  }

  async getById(userId: string, goalId: string) {
    const goal = await prisma.goal.findFirst({
      where: { id: goalId, userId, deletedAt: null },
      include: {
        targetProduct: {
          include: {
            images: { orderBy: [{ sortOrder: "asc" }] },
          },
        },
      },
    });

    if (!goal) {
      throw new AppError(404, "NOT_FOUND", "Goal does not exist");
    }

    const rate = await goldRatesService.currentRateForPurity(
      GOAL_ACCUMULATION_PURITY,
    );
    const currentGrams = await goldLedgerService.getGoalCreditedGrams(goalId);
    const completedInstallments = isAuraScheme(goal.schemeType)
      ? await countCompletedAuraInstallments(goalId)
      : isCrestScheme(goal.schemeType)
        ? await countCompletedCrestPayments(goalId)
        : 0;

    const contributions = await prisma.contribution.findMany({
      where: { goalId, userId },
      orderBy: { contributionMonth: "desc" },
      take: 24,
    });

    const balance = await goldLedgerService.getPostedBalanceGrams(userId);
    const balanceValuePaise = goldLedgerService.balanceValuePaise(
      balance,
      rate.ratePerGramPaise,
    );

    const products = await prisma.product.findMany({
      where: { isPublished: true, deletedAt: null },
      include: productInclude(),
      take: 50,
    });

    const redeemable = (
      await Promise.all(products.map((product) => mapProductToDto(product)))
    ).filter((product) => product.price.total_paise <= balanceValuePaise);

    return {
      goal: mapGoalToDto(
        goal,
        currentGrams,
        rate.ratePerGramPaise,
        completedInstallments,
      ),
      contributions: contributions.map((row) => ({
        id: row.id,
        amount_paise: row.amountPaise,
        grams_credited: row.gramsCredited
          ? decimalString(row.gramsCredited)
          : null,
        type: row.type,
        status: row.status,
        contribution_month: formatDateOnly(row.contributionMonth),
        completed_at: row.completedAt?.toISOString() ?? null,
      })),
      redeemable_products: redeemable.slice(0, 10),
    };
  }

  async patch(userId: string, goalId: string, input: PatchGoalInput) {
    const goal = await prisma.goal.findFirst({
      where: { id: goalId, userId, deletedAt: null },
      include: {
        targetProduct: {
          include: {
            images: { orderBy: [{ sortOrder: "asc" }] },
          },
        },
      },
    });

    if (!goal) {
      throw new AppError(404, "NOT_FOUND", "Goal does not exist");
    }

    if (goal.status === "completed" || goal.status === "cancelled" || goal.status === "discontinued") {
      throw new AppError(409, "CONFLICT", "Goal cannot be updated");
    }

    if (input.status === "paused" && goal.status === "paused") {
      throw new AppError(409, "CONFLICT", "Goal is already paused");
    }

    if (input.status === "active" && goal.status === "active") {
      throw new AppError(409, "CONFLICT", "Goal is already active");
    }

    const now = new Date();
    const updated = await prisma.goal.update({
      where: { id: goalId },
      data: {
        ...(input.name !== undefined ? { name: input.name } : {}),
        ...(input.status === "paused"
          ? { status: "paused", pausedAt: now }
          : {}),
        ...(input.status === "active"
          ? { status: "active", pausedAt: null }
          : {}),
      },
      include: {
        targetProduct: {
          include: {
            images: { orderBy: [{ sortOrder: "asc" }] },
          },
        },
      },
    });

    const rate = await goldRatesService.currentRateForPurity(
      GOAL_ACCUMULATION_PURITY,
    );
    const currentGrams = await goldLedgerService.getGoalCreditedGrams(goalId);
    const completedInstallments = isAuraScheme(updated.schemeType)
      ? await countCompletedAuraInstallments(goalId)
      : isCrestScheme(updated.schemeType)
        ? await countCompletedCrestPayments(goalId)
        : 0;

    return {
      goal: mapGoalToDto(
        updated,
        currentGrams,
        rate.ratePerGramPaise,
        completedInstallments,
      ),
    };
  }

  async cancel(userId: string, goalId: string) {
    const goal = await prisma.goal.findFirst({
      where: { id: goalId, userId, deletedAt: null },
    });

    if (!goal) {
      throw new AppError(404, "NOT_FOUND", "Goal does not exist");
    }

    if (goal.status === "cancelled") {
      throw new AppError(409, "CONFLICT", "Goal is already cancelled");
    }

    const retainedGrams = await goldLedgerService.getGoalCreditedGrams(goalId);
    const now = new Date();

    await prisma.goal.update({
      where: { id: goalId },
      data: {
        status: "cancelled",
        cancelledAt: now,
        deletedAt: now,
      },
    });

    return {
      success: true,
      gold_retained_grams: decimalString(retainedGrams),
      message: "Your accumulated gold is retained in your balance.",
    };
  }

  async contribute(
    userId: string,
    kycStatus: KycStatus,
    goalId: string,
    input: ContributeInput,
    idempotencyKey: string,
  ) {
    return withIdempotency({
      userId,
      scope: "goals.contribute",
      key: idempotencyKey,
      requestBody: input,
      resourceType: "contribution",
      handler: async () =>
        contributionsService.initiateManualContribution({
          userId,
          kycStatus,
          goalId,
          amountPaise: input.amount_paise,
          paymentMethodId: input.payment_method_id,
        }),
    });
  }
}

export const goalsService = new GoalsService();
