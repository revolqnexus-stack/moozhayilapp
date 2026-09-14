import type { Contribution, Goal, KycStatus } from "@prisma/client";
import { prisma } from "../../db/prisma";
import { loadEnv } from "../../config/env";
import { AppError } from "../../middleware/error.middleware";
import { calculateGramsFromPaise } from "../../utils/gold";
import { formatPaise } from "../../utils/money";
import { goldRatesService } from "../gold_rates/gold_rates.service";
import { GOAL_ACCUMULATION_PURITY } from "../../config/goals.constants";
import { goldLedgerService } from "../gold_ledger/gold_ledger.service";
import { goldBalanceService } from "../gold_ledger/gold_balance.service";
import { checkContributionGate } from "../../utils/kyc_gates";
import { toDateOnly, formatDateOnly, addMonths } from "../../utils/dates";
import {
  isAuraScheme,
  validateAuraContributionAmount,
} from "../goals/aura.service";
import {
  countCompletedCrestPayments,
  isCrestScheme,
  validateCrestContributionAmount,
} from "../goals/crest.service";
import {
  isDhanamScheme,
  resolveDhanamCreditRate,
  validateDhanamContributionAmount,
} from "../goals/dhanam.service";
import {
  isGoldNidhiScheme,
  validateGoldNidhiContributionAmount,
} from "../goals/gold_nidhi.service";
import { detectMilestones } from "./milestones.service";
import { evaluateGoalCompletion } from "./goal_completion.service";
import {
  notifyContributionFailed,
  notifyContributionSuccess,
} from "../notifications/notifications.triggers";
import { referralsService } from "../referrals/referrals.service";
import { formatGoldGrams } from "../../utils/gold";
import { paymentProviderClient } from "../payments/payment_provider.client";
import { withIdempotency } from "../../utils/idempotency";

const COMPLETABLE_STATUSES = [
  "pending_payment",
  "processing",
  "scheduled",
] as const;

export class ContributionsService {
  async listPending(userId: string) {
    const pending = await prisma.contribution.findMany({
      where: {
        userId,
        status: { in: ["pending_payment", "processing"] },
      },
      orderBy: { createdAt: "desc" },
    });

    return {
      pending: pending.map((row) => ({
        id: row.id,
        goal_id: row.goalId,
        status: row.status,
        created_at: row.createdAt.toISOString(),
      })),
    };
  }

  async initiateManualContribution(input: {
    userId: string;
    kycStatus: KycStatus;
    goalId: string;
    amountPaise: number;
    paymentMethodId?: string;
  }) {
    const gate = checkContributionGate(input.kycStatus, input.amountPaise);
    if (!gate.allowed) {
      throw new AppError(403, gate.code ?? "KYC_REQUIRED", gate.message ?? "");
    }

    const goal = await prisma.goal.findFirst({
      where: {
        id: input.goalId,
        userId: input.userId,
        deletedAt: null,
      },
    });

    if (!goal) {
      throw new AppError(404, "NOT_FOUND", "Goal does not exist");
    }

    await this.validateGoalContributionAmount(goal, input.amountPaise);

    if (input.paymentMethodId) {
      const paymentMethod = await prisma.paymentMethod.findFirst({
        where: {
          id: input.paymentMethodId,
          userId: input.userId,
          deletedAt: null,
        },
      });

      if (!paymentMethod) {
        throw new AppError(404, "NOT_FOUND", "Payment method does not exist");
      }
    }

    const rate = await goldRatesService.currentRateForPurity(GOAL_ACCUMULATION_PURITY);
    let creditRatePaise = rate.ratePerGramPaise;

    if (
      isDhanamScheme(goal.schemeType) &&
      goal.bookingRatePaisePerGram != null
    ) {
      creditRatePaise = resolveDhanamCreditRate(
        goal.bookingRatePaisePerGram,
        rate.ratePerGramPaise,
      );
    }

    const contributionMonth = isAuraScheme(goal.schemeType)
      ? toDateOnly(goal.nextContributionDate)
      : toDateOnly(new Date());

    const contribution = await prisma.contribution.create({
      data: {
        goalId: goal.id,
        userId: input.userId,
        amountPaise: input.amountPaise,
        goldRatePerGramPaise: creditRatePaise,
        contributionMonth,
        type: "manual",
        status: "pending_payment",
        paymentMethodId: input.paymentMethodId ?? null,
      },
    });

    const env = loadEnv();
    if (env.PAYMENT_PROVIDER_MODE === "mock") {
      const completed = await this.completeContribution({
        contributionId: contribution.id,
      });

      return {
        contribution: {
          id: completed.id,
          status: completed.status,
          amount_paise: completed.amountPaise,
          amount_display: formatPaise(completed.amountPaise),
        },
        payment_required: false,
        payment_session_id: null,
      };
    }

    const paymentSession = await this.initiateContributionPayment(contribution.id);

    return {
      contribution: {
        id: contribution.id,
        status: "pending_payment",
        amount_paise: contribution.amountPaise,
        amount_display: formatPaise(contribution.amountPaise),
      },
      payment_required: true,
      payment_session_id: paymentSession.providerSessionId ?? paymentSession.id,
      razorpay_order_id: paymentSession.providerOrderId,
      razorpay_key_id: env.RAZORPAY_KEY_ID ?? null,
      cashfree_order_id: paymentSession.providerOrderId,
      cashfree_app_id: env.CASHFREE_APP_ID ?? null,
    };
  }

  async initiateContributionPayment(contributionId: string) {
    const contribution = await prisma.contribution.findUnique({
      where: { id: contributionId },
    });

    if (!contribution) {
      throw new AppError(404, "NOT_FOUND", "Contribution does not exist");
    }

    if (contribution.paymentTransactionId) {
      return prisma.paymentTransaction.findUniqueOrThrow({
        where: { id: contribution.paymentTransactionId },
      });
    }

    const providerOrder = await paymentProviderClient.createOrder({
      amountPaise: contribution.amountPaise,
      orderId: contribution.id,
      customerId: contribution.userId,
      customerPhone: (
        await prisma.user.findUniqueOrThrow({
          where: { id: contribution.userId },
        })
      ).phone,
    });

    const env = loadEnv();
    const paymentTx = await prisma.$transaction(async (tx) => {
      const created = await tx.paymentTransaction.create({
        data: {
          userId: contribution.userId,
          type: "goal_contribution",
          status: "created",
          amountPaise: contribution.amountPaise,
          providerOrderId: providerOrder.providerOrderId,
          providerSessionId: providerOrder.paymentSessionId,
          provider: env.PAYMENT_PROVIDER ?? "razorpay",
          idempotencyKey: `contribution_payment:${contribution.id}`,
        },
      });

      await tx.contribution.update({
        where: { id: contribution.id },
        data: {
          paymentTransactionId: created.id,
          status: "pending_payment",
        },
      });

      return created;
    });

    return paymentTx;
  }

  async completeContribution(input: {
    contributionId: string;
  }): Promise<Contribution> {
    const contribution = await prisma.contribution.findUnique({
      where: { id: input.contributionId },
      include: { goal: true },
    });

    if (!contribution) {
      throw new AppError(404, "NOT_FOUND", "Contribution does not exist");
    }

    if (contribution.status === "completed") {
      return contribution;
    }

    if (
      !COMPLETABLE_STATUSES.includes(
        contribution.status as (typeof COMPLETABLE_STATUSES)[number],
      )
    ) {
      throw new AppError(
        409,
        "CONFLICT",
        "Contribution cannot be completed from current status",
      );
    }

    const gramsCredited = calculateGramsFromPaise(
      contribution.amountPaise,
      contribution.goldRatePerGramPaise,
    );
    const now = new Date();

    const completed = await prisma.$transaction(async (tx) => {
      const transition = await tx.contribution.updateMany({
        where: {
          id: contribution.id,
          status: { in: [...COMPLETABLE_STATUSES] },
        },
        data: {
          status: "completed",
          gramsCredited: gramsCredited.toFixed(4),
          completedAt: now,
        },
      });

      if (transition.count === 0) {
        const current = await tx.contribution.findUnique({
          where: { id: contribution.id },
        });

        if (current?.status === "completed") {
          return current;
        }

        throw new AppError(
          409,
          "CONFLICT",
          "Contribution cannot be completed from current status",
        );
      }

      const updated = await tx.contribution.findUniqueOrThrow({
        where: { id: contribution.id },
      });

      await goldLedgerService.postContributionCredit({
        userId: contribution.userId,
        contributionId: contribution.id,
        amountPaise: contribution.amountPaise,
        goldRatePerGramPaise: contribution.goldRatePerGramPaise,
        tx,
      });

      await tx.goal.update({
        where: { id: contribution.goalId },
        data: {
          nextContributionDate: toDateOnly(
            addMonths(contribution.goal.nextContributionDate, 1),
          ),
          ...(contribution.goal.status === "contribution_due" ||
          contribution.goal.status === "paused"
            ? { status: "active", pausedAt: null }
            : {}),
        },
      });

      return updated;
    });

    await goldBalanceService.refreshSnapshot(
      contribution.userId,
      "contribution_completed",
    );
    await detectMilestones(contribution.userId);
    await evaluateGoalCompletion(contribution.goalId);

    await notifyContributionSuccess({
      userId: contribution.userId,
      goalId: contribution.goalId,
      goalName: contribution.goal.name,
      gramsDisplay: formatGoldGrams(gramsCredited),
      contributionId: contribution.id,
    });

    await referralsService.processRewardForFirstContribution(contribution.userId);

    return completed;
  }

  async failContribution(contributionId: string) {
    const contribution = await prisma.contribution.update({
      where: { id: contributionId },
      data: {
        status: "payment_failed",
        failedAt: new Date(),
      },
      include: { goal: true },
    });

    await notifyContributionFailed({
      userId: contribution.userId,
      goalId: contribution.goalId,
      goalName: contribution.goal.name,
      amountDisplay: formatPaise(contribution.amountPaise),
    });

    return contribution;
  }

  async createScheduledContribution(goal: Goal, contributionMonth: Date) {
    const rate = await goldRatesService.currentRateForPurity(GOAL_ACCUMULATION_PURITY);

    return prisma.contribution.create({
      data: {
        goalId: goal.id,
        userId: goal.userId,
        amountPaise: goal.monthlyAmountPaise,
        goldRatePerGramPaise: rate.ratePerGramPaise,
        contributionMonth: toDateOnly(contributionMonth),
        type: "autopay",
        status: "scheduled",
        paymentMethodId: goal.paymentMethodId,
      },
    });
  }

  contributionMonthLabel(date: Date): string {
    return formatDateOnly(date).slice(0, 7);
  }

  async recordAdminShowroomPayment(input: {
    goalId: string;
    adminId: string;
    amountPaise: number;
    paymentChannel: "cash" | "upi" | "bank_transfer" | "cheque" | "other";
    referenceNumber?: string;
    remarks?: string;
    idempotencyKey: string;
  }) {
    return withIdempotency({
      userId: input.adminId,
      scope: "admin.contributions.showroom",
      key: input.idempotencyKey,
      requestBody: {
        goal_id: input.goalId,
        amount_paise: input.amountPaise,
        payment_channel: input.paymentChannel,
        reference_number: input.referenceNumber,
        remarks: input.remarks,
      },
      resourceType: "contribution",
      handler: () => this.executeAdminShowroomPayment(input),
    });
  }

  private async validateGoalContributionAmount(goal: Goal, amountPaise: number) {
    if (goal.status === "cancelled" || goal.status === "completed") {
      throw new AppError(409, "CONFLICT", "Goal is not accepting contributions");
    }

    if (goal.status === "discontinued") {
      throw new AppError(409, "CONFLICT", "Goal is not accepting contributions");
    }

    if (isAuraScheme(goal.schemeType)) {
      validateAuraContributionAmount(goal, amountPaise);
    } else if (isCrestScheme(goal.schemeType)) {
      const completed = await countCompletedCrestPayments(goal.id);
      validateCrestContributionAmount(goal, amountPaise, completed);
    } else if (isDhanamScheme(goal.schemeType)) {
      validateDhanamContributionAmount(goal, amountPaise);
    } else if (isGoldNidhiScheme(goal.schemeType)) {
      validateGoldNidhiContributionAmount(amountPaise);
    }
  }

  private async executeAdminShowroomPayment(input: {
    goalId: string;
    adminId: string;
    amountPaise: number;
    paymentChannel: "cash" | "upi" | "bank_transfer" | "cheque" | "other";
    referenceNumber?: string;
    remarks?: string;
    idempotencyKey: string;
  }) {
    const goal = await prisma.goal.findFirst({
      where: {
        id: input.goalId,
        deletedAt: null,
      },
    });

    if (!goal) {
      throw new AppError(404, "NOT_FOUND", "Goal does not exist");
    }

    await this.validateGoalContributionAmount(goal, input.amountPaise);

    const rate = await goldRatesService.currentRateForPurity(GOAL_ACCUMULATION_PURITY);
    let creditRatePaise = rate.ratePerGramPaise;

    if (
      isDhanamScheme(goal.schemeType) &&
      goal.bookingRatePaisePerGram != null
    ) {
      creditRatePaise = resolveDhanamCreditRate(
        goal.bookingRatePaisePerGram,
        rate.ratePerGramPaise,
      );
    }

    const contributionMonth = isAuraScheme(goal.schemeType)
      ? toDateOnly(goal.nextContributionDate)
      : toDateOnly(new Date());

    const contribution = await prisma.$transaction(async (tx) => {
      const paymentTx = await tx.paymentTransaction.create({
        data: {
          userId: goal.userId,
          type: "goal_contribution",
          status: "reconciled",
          amountPaise: input.amountPaise,
          providerOrderId: input.referenceNumber
            ? `showroom:${input.referenceNumber}`
            : `showroom:${goal.id}:${input.idempotencyKey.slice(0, 12)}`,
          providerPaymentId: `admin_showroom:${input.idempotencyKey}`,
          idempotencyKey: `admin_showroom_payment:${input.idempotencyKey}`,
        },
      });

      return tx.contribution.create({
        data: {
          goalId: goal.id,
          userId: goal.userId,
          amountPaise: input.amountPaise,
          goldRatePerGramPaise: creditRatePaise,
          contributionMonth,
          type: "manual",
          status: "scheduled",
          paymentTransactionId: paymentTx.id,
        },
      });
    });

    const completed = await this.completeContribution({
      contributionId: contribution.id,
    });

    return {
      contribution: {
        id: completed.id,
        status: completed.status,
        amount_paise: completed.amountPaise,
        amount_display: formatPaise(completed.amountPaise),
        grams_credited: completed.gramsCredited,
      },
      payment_channel: input.paymentChannel,
      reference_number: input.referenceNumber ?? null,
      remarks: input.remarks ?? null,
    };
  }

  async listForGoal(goalId: string) {
    const goal = await prisma.goal.findFirst({
      where: { id: goalId, deletedAt: null },
      select: {
        id: true,
        name: true,
        schemeType: true,
        userId: true,
        status: true,
      },
    });

    if (!goal) {
      throw new AppError(404, "NOT_FOUND", "Goal does not exist");
    }

    const contributions = await prisma.contribution.findMany({
      where: { goalId },
      orderBy: { createdAt: "desc" },
      take: 50,
    });

    return {
      goal: {
        id: goal.id,
        name: goal.name,
        scheme_type: goal.schemeType,
        user_id: goal.userId,
        status: goal.status,
      },
      contributions: contributions.map((row) => ({
        id: row.id,
        amount_paise: row.amountPaise,
        amount_display: formatPaise(row.amountPaise),
        status: row.status,
        type: row.type,
        contribution_month: formatDateOnly(row.contributionMonth),
        completed_at: row.completedAt?.toISOString() ?? null,
        grams_credited: row.gramsCredited,
      })),
    };
  }
}

export const contributionsService = new ContributionsService();
