import type { Prisma } from "@prisma/client";
import { Prisma as PrismaClient } from "@prisma/client";
import { randomUUID } from "crypto";
import Decimal from "decimal.js";
import type { LedgerEntryType } from "@prisma/client";
import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import {
  calculateGramsFromPaise,
  calculateValuePaiseFromGrams,
  decimalString,
} from "../../utils/gold";
import {
  bonusCreditLedgerKey,
  contributionCreditLedgerKey,
  POSTED_CREDIT_ENTRY_TYPES,
  redemptionDebitLedgerKey,
  refundCreditLedgerKey,
} from "../../utils/ledger_keys";

export class GoldLedgerService {
  async getPostedBalanceGrams(
    userId: string,
    tx?: Prisma.TransactionClient,
  ): Promise<Decimal> {
    const db = tx ?? prisma;
    const aggregate = await db.goldLedgerEntry.aggregate({
      where: { userId, status: "posted" },
      _sum: { gramsDelta: true },
    });

    return new Decimal(aggregate._sum.gramsDelta ?? 0);
  }

  /**
   * Goal progress is derived exclusively from posted ledger credits tied to
   * completed contributions for the goal — never from contribution.grams_credited
   * or balance snapshots.
   */
  async getGoalCreditedGrams(goalId: string): Promise<Decimal> {
    const contributions = await prisma.contribution.findMany({
      where: { goalId, status: "completed" },
      select: { id: true },
    });

    if (contributions.length === 0) {
      return new Decimal(0);
    }

    const aggregate = await prisma.goldLedgerEntry.aggregate({
      where: {
        sourceType: "contribution",
        sourceId: { in: contributions.map((row) => row.id) },
        status: "posted",
        entryType: { in: POSTED_CREDIT_ENTRY_TYPES },
      },
      _sum: { gramsDelta: true },
    });

    return new Decimal(aggregate._sum.gramsDelta ?? 0);
  }

  private async findPostedCreditBySource(input: {
    db: Prisma.TransactionClient | typeof prisma;
    sourceId: string;
    entryType: LedgerEntryType;
  }) {
    return input.db.goldLedgerEntry.findFirst({
      where: {
        sourceType: "contribution",
        sourceId: input.sourceId,
        entryType: input.entryType,
        status: "posted",
      },
    });
  }

  async postContributionCredit(input: {
    userId: string;
    contributionId: string;
    amountPaise: number;
    goldRatePerGramPaise: number;
    /** When set (e.g. CREST locked weight), ledger matches this instead of amount÷rate. */
    gramsDelta?: Decimal.Value;
    tx?: Prisma.TransactionClient;
  }) {
    const db = input.tx ?? prisma;
    const idempotencyKey = contributionCreditLedgerKey(input.contributionId);

    const existingBySource = await this.findPostedCreditBySource({
      db,
      sourceId: input.contributionId,
      entryType: "contribution_credit",
    });

    if (existingBySource) {
      return existingBySource;
    }

    const gramsDelta =
      input.gramsDelta != null
        ? new Decimal(input.gramsDelta)
        : calculateGramsFromPaise(
            input.amountPaise,
            input.goldRatePerGramPaise,
          );

    if (gramsDelta.lte(0)) {
      throw new AppError(
        422,
        "UNPROCESSABLE",
        "Contribution amount is too small to credit gold",
      );
    }

    const existingByKey = await db.goldLedgerEntry.findUnique({
      where: { idempotencyKey },
    });

    if (existingByKey) {
      return existingByKey;
    }

    const now = new Date();

    try {
      return await db.goldLedgerEntry.create({
        data: {
          userId: input.userId,
          entryType: "contribution_credit",
          status: "posted",
          gramsDelta: gramsDelta.toFixed(4),
          amountPaise: input.amountPaise,
          goldRatePerGramPaise: input.goldRatePerGramPaise,
          sourceType: "contribution",
          sourceId: input.contributionId,
          correlationId: randomUUID(),
          idempotencyKey,
          postedAt: now,
        },
      });
    } catch (error) {
      if (
        error instanceof PrismaClient.PrismaClientKnownRequestError &&
        error.code === "P2002"
      ) {
        const raced = await this.findPostedCreditBySource({
          db,
          sourceId: input.contributionId,
          entryType: "contribution_credit",
        });
        if (raced) {
          return raced;
        }
      }

      throw error;
    }
  }

  async postBonusCredit(input: {
    userId: string;
    contributionId: string;
    amountPaise: number;
    goldRatePerGramPaise: number;
    tx?: Prisma.TransactionClient;
  }) {
    const db = input.tx ?? prisma;
    const idempotencyKey = bonusCreditLedgerKey(input.contributionId);

    const existingBySource = await this.findPostedCreditBySource({
      db,
      sourceId: input.contributionId,
      entryType: "bonus_credit",
    });

    if (existingBySource) {
      return existingBySource;
    }

    const gramsDelta = calculateGramsFromPaise(
      input.amountPaise,
      input.goldRatePerGramPaise,
    );

    const existingByKey = await db.goldLedgerEntry.findUnique({
      where: { idempotencyKey },
    });

    if (existingByKey) {
      return existingByKey;
    }

    const now = new Date();

    try {
      return await db.goldLedgerEntry.create({
        data: {
          userId: input.userId,
          entryType: "bonus_credit",
          status: "posted",
          gramsDelta: gramsDelta.toFixed(4),
          amountPaise: input.amountPaise,
          goldRatePerGramPaise: input.goldRatePerGramPaise,
          sourceType: "contribution",
          sourceId: input.contributionId,
          correlationId: randomUUID(),
          idempotencyKey,
          postedAt: now,
        },
      });
    } catch (error) {
      if (
        error instanceof PrismaClient.PrismaClientKnownRequestError &&
        error.code === "P2002"
      ) {
        const raced = await this.findPostedCreditBySource({
          db,
          sourceId: input.contributionId,
          entryType: "bonus_credit",
        });
        if (raced) {
          return raced;
        }
      }

      throw error;
    }
  }

  async listEntries(input: {
    userId: string;
    goalId?: string;
    cursor?: string;
    limit: number;
  }) {
    if (input.goalId) {
      const goal = await prisma.goal.findFirst({
        where: {
          id: input.goalId,
          userId: input.userId,
          deletedAt: null,
        },
        select: { id: true },
      });

      if (!goal) {
        throw new AppError(404, "NOT_FOUND", "Goal does not exist");
      }
    }

    if (input.cursor) {
      const cursorEntry = await prisma.goldLedgerEntry.findFirst({
        where: { id: input.cursor, userId: input.userId },
        select: { id: true },
      });

      if (!cursorEntry) {
        throw new AppError(400, "BAD_REQUEST", "Invalid ledger cursor");
      }
    }

    const contributions = input.goalId
      ? await prisma.contribution.findMany({
          where: { goalId: input.goalId, userId: input.userId },
          select: { id: true },
        })
      : [];

    const sourceIds = contributions.map((row) => row.id);

    const where: Prisma.GoldLedgerEntryWhereInput = {
      userId: input.userId,
      status: "posted",
      ...(input.goalId
        ? {
            sourceType: "contribution",
            sourceId: { in: sourceIds },
          }
        : {}),
    };

    const rows = await prisma.goldLedgerEntry.findMany({
      where,
      orderBy: { postedAt: "desc" },
      take: input.limit + 1,
      ...(input.cursor
        ? {
            cursor: { id: input.cursor },
            skip: 1,
          }
        : {}),
    });

    const hasMore = rows.length > input.limit;
    const data = hasMore ? rows.slice(0, input.limit) : rows;

    return {
      data: data.map((row) => ({
        id: row.id,
        entry_type: row.entryType,
        grams_delta: decimalString(row.gramsDelta),
        amount_paise: row.amountPaise,
        gold_rate_per_gram_paise: row.goldRatePerGramPaise,
        source_type: row.sourceType,
        source_id: row.sourceId,
        posted_at: row.postedAt.toISOString(),
      })),
      next_cursor: hasMore ? data[data.length - 1]?.id ?? null : null,
      has_more: hasMore,
    };
  }

  balanceValuePaise(grams: Decimal, ratePerGramPaise: number): number {
    return calculateValuePaiseFromGrams(grams, ratePerGramPaise);
  }

  async postRedemptionDebit(input: {
    userId: string;
    orderId: string;
    gramsDelta: Decimal;
    amountPaise: number;
    goldRatePerGramPaise: number;
    tx?: Prisma.TransactionClient;
  }) {
    const db = input.tx ?? prisma;
    const idempotencyKey = redemptionDebitLedgerKey(input.orderId);

    const existing = await db.goldLedgerEntry.findFirst({
      where: {
        sourceType: "order",
        sourceId: input.orderId,
        entryType: "redemption_debit",
        status: "posted",
      },
    });

    if (existing) {
      return existing;
    }

    const balance = await this.getPostedBalanceGrams(input.userId, db);
    if (balance.lt(input.gramsDelta)) {
      throw new AppError(
        422,
        "INSUFFICIENT_BALANCE",
        "Insufficient gold balance for redemption",
      );
    }

    const now = new Date();
    const negativeGrams = input.gramsDelta.neg();

    return db.goldLedgerEntry.create({
      data: {
        userId: input.userId,
        entryType: "redemption_debit",
        status: "posted",
        gramsDelta: negativeGrams.toFixed(4),
        amountPaise: input.amountPaise,
        goldRatePerGramPaise: input.goldRatePerGramPaise,
        sourceType: "order",
        sourceId: input.orderId,
        correlationId: randomUUID(),
        idempotencyKey,
        postedAt: now,
      },
    });
  }

  async postRefundCredit(input: {
    userId: string;
    orderId: string;
    gramsDelta: Decimal;
    amountPaise: number;
    goldRatePerGramPaise: number;
    tx?: Prisma.TransactionClient;
  }) {
    const db = input.tx ?? prisma;
    const idempotencyKey = refundCreditLedgerKey(input.orderId);

    const existing = await db.goldLedgerEntry.findFirst({
      where: {
        sourceType: "order",
        sourceId: input.orderId,
        entryType: "refund_credit",
        status: "posted",
      },
    });

    if (existing) {
      return existing;
    }

    const now = new Date();

    return db.goldLedgerEntry.create({
      data: {
        userId: input.userId,
        entryType: "refund_credit",
        status: "posted",
        gramsDelta: input.gramsDelta.toFixed(4),
        amountPaise: input.amountPaise,
        goldRatePerGramPaise: input.goldRatePerGramPaise,
        sourceType: "order",
        sourceId: input.orderId,
        correlationId: randomUUID(),
        idempotencyKey,
        postedAt: now,
      },
    });
  }
}

export const goldLedgerService = new GoldLedgerService();

export type LedgerEntryTypeAlias = LedgerEntryType;
