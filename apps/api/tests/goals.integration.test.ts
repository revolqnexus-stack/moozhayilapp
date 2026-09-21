import request from "supertest";
import { createApp } from "../src/app";
import { prisma } from "../src/db/prisma";
import { clearRateLimitBucketsForTests } from "../src/middleware/rate_limit.middleware";
import {
  processContributionDueStatuses,
  processDueAutopayContributions,
} from "../src/jobs/processors/autopay.processor";
import { calculateGramsFromPaise } from "../src/utils/gold";

async function cleanPhase7Tables() {
  await prisma.idempotencyKey.deleteMany();
  await prisma.userMilestone.deleteMany();
  await prisma.goldBalanceSnapshot.deleteMany();
  await prisma.goldLedgerEntry.deleteMany();
  await prisma.contribution.deleteMany();
  await prisma.goal.deleteMany();
  await prisma.paymentMethod.deleteMany();
  await prisma.cartItem.deleteMany();
  await prisma.dreamVaultItem.deleteMany();
  await prisma.productOccasionTag.deleteMany();
  await prisma.productImage.deleteMany();
  await prisma.product.deleteMany();
  await prisma.goldRateHistory.deleteMany();
  await prisma.category.deleteMany();
  await prisma.auditLog.deleteMany();
  await prisma.kycAadhaarSession.deleteMany();
  await prisma.kycDocument.deleteMany();
  await prisma.authSession.deleteMany();
  await prisma.otpSession.deleteMany();
  await prisma.userIntent.deleteMany();
  await prisma.userDevice.deleteMany();
  await prisma.user.deleteMany();
}

async function signIn(app: ReturnType<typeof createApp>, phone: string) {
  const sendResponse = await request(app)
    .post("/v1/auth/send-otp")
    .send({ phone });

  const verifyResponse = await request(app)
    .post("/v1/auth/verify-otp")
    .send({
      otp_session_id: sendResponse.body.otp_session_id,
      otp: "123456",
    });

  return {
    accessToken: verifyResponse.body.access_token as string,
    userId: verifyResponse.body.user.id as string,
  };
}

async function verifyUser(userId: string) {
  await prisma.user.update({
    where: { id: userId },
    data: { kycStatus: "basic_verified" },
  });
}

function daysAgo(days: number): Date {
  const date = new Date();
  date.setUTCHours(0, 0, 0, 0);
  date.setUTCDate(date.getUTCDate() - days);
  return date;
}

async function seedCatalog() {
  const category = await prisma.category.create({
    data: { name: "Bangles", slug: "bangles" },
  });

  await prisma.goldRateHistory.create({
    data: {
      purity: "k22",
      ratePerGramPaise: 624000,
      effectiveFrom: new Date("2026-06-26T04:30:00Z"),
      source: "test",
    },
  });

  const product = await prisma.product.create({
    data: {
      sku: "MGD-P7-001",
      name: "Temple Bangle",
      categoryId: category.id,
      purity: "k22",
      weightGrams: "1.0000",
      makingChargePct: "12.00",
      stockQuantity: 5,
      isPublished: true,
    },
  });

  return product;
}

describe("Phase 7 goals, contributions, and gold ledger", () => {
  const app = createApp();

  beforeAll(() => {
    process.env.NODE_ENV = "test";
    process.env.TEST_OTP_CODE = "123456";
    process.env.PAYMENT_PROVIDER_MODE = "mock";
  });

  beforeEach(async () => {
    clearRateLimitBucketsForTests();
    await cleanPhase7Tables();
  });

  afterAll(async () => {
    await cleanPhase7Tables();
    await prisma.$disconnect();
  });

  it("creates a goal, posts ledger on contribution, and derives gold balance", async () => {
    await seedCatalog();
    const auth = await signIn(app, "+919876543210");
    await verifyUser(auth.userId);

    const createResponse = await request(app)
      .post("/v1/goals")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .set("Idempotency-Key", "goal-create-1")
      .send({
        goal_type: "wedding",
        name: "Wedding Bangles",
        monthly_amount_paise: 300000,
        duration_months: 11,
        start_date: "2026-07-01",
        target_amount_paise: 5000000,
      });

    expect(createResponse.status).toBe(201);
    expect(createResponse.body.goal.name).toBe("Wedding Bangles");
    expect(createResponse.body.first_contribution_scheduled).toBe("2026-07-01");

    const goalId = createResponse.body.goal.id as string;

    const contributeResponse = await request(app)
      .post(`/v1/goals/${goalId}/contribute`)
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .set("Idempotency-Key", "contrib-1")
      .send({ amount_paise: 300000 });

    expect(contributeResponse.status).toBe(200);
    expect(contributeResponse.body.contribution.status).toBe("completed");
    expect(contributeResponse.body.payment_required).toBe(false);

    const balanceResponse = await request(app)
      .get("/v1/gold-balance")
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(balanceResponse.status).toBe(200);
    expect(balanceResponse.body.total_grams).toBe("0.4807");

    const ledgerResponse = await request(app)
      .get("/v1/gold-balance/ledger")
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(ledgerResponse.status).toBe(200);
    expect(ledgerResponse.body.data).toHaveLength(1);
    expect(ledgerResponse.body.data[0].entry_type).toBe("contribution_credit");
    expect(ledgerResponse.body.data[0].grams_delta).toBe("0.4807");

    const meResponse = await request(app)
      .get("/v1/user/me")
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(meResponse.body.active_goals_count).toBe(1);
  });

  it("floors grams to four decimals when crediting ledger", () => {
    const grams = calculateGramsFromPaise(100, 624000);
    expect(grams.toFixed(4)).toBe("0.0001");
  });

  it("marks overdue goals as contribution_due and paused", async () => {
    await seedCatalog();
    const auth = await signIn(app, "+919876543211");
    await verifyUser(auth.userId);

    const dueGoal = await prisma.goal.create({
      data: {
        userId: auth.userId,
        name: "Due Goal",
        schemeType: "crest",
        goalType: "investment",
        monthlyAmountPaise: 300000,
        durationMonths: 12,
        startDate: daysAgo(40),
        nextContributionDate: daysAgo(10),
        targetAmountPaise: 5000000,
      },
    });

    const dueUpdated = await processContributionDueStatuses();
    expect(dueUpdated).toBeGreaterThan(0);

    const refreshedDue = await prisma.goal.findUnique({
      where: { id: dueGoal.id },
    });
    expect(refreshedDue?.status).toBe("contribution_due");

    const pausedGoal = await prisma.goal.create({
      data: {
        userId: auth.userId,
        name: "Paused Goal",
        schemeType: "crest",
        goalType: "investment",
        monthlyAmountPaise: 300000,
        durationMonths: 12,
        startDate: daysAgo(70),
        nextContributionDate: daysAgo(35),
        targetAmountPaise: 5000000,
      },
    });

    await processContributionDueStatuses();
    const refreshedPaused = await prisma.goal.findUnique({
      where: { id: pausedGoal.id },
    });
    expect(refreshedPaused?.status).toBe("paused");
    expect(refreshedPaused?.bonusEligible).toBe(false);
  });

  it("processes autopay contributions for due goals in mock mode", async () => {
    await seedCatalog();
    const auth = await signIn(app, "+919876543212");
    await verifyUser(auth.userId);

    const goal = await prisma.goal.create({
      data: {
        userId: auth.userId,
        name: "Autopay Goal",
        schemeType: "crest",
        goalType: "festival",
        monthlyAmountPaise: 624000,
        durationMonths: 12,
        startDate: new Date("2026-06-01"),
        nextContributionDate: new Date("2026-06-01"),
        targetAmountPaise: 10_000_000,
      },
    });

    const processed = await processDueAutopayContributions();
    expect(processed).toBe(1);

    const contribution = await prisma.contribution.findFirst({
      where: { goalId: goal.id, type: "autopay" },
    });
    expect(contribution?.status).toBe("completed");

    const ledger = await prisma.goldLedgerEntry.findMany({
      where: { userId: auth.userId },
    });
    expect(ledger).toHaveLength(1);
    expect(Number(ledger[0]?.gramsDelta)).toBe(1);
  });

  it("rejects goal creation without KYC", async () => {
    await seedCatalog();
    const auth = await signIn(app, "+919876543213");

    const response = await request(app)
      .post("/v1/goals")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .set("Idempotency-Key", "goal-no-kyc")
      .send({
        goal_type: "wedding",
        name: "Blocked Goal",
        monthly_amount_paise: 300000,
        duration_months: 11,
        start_date: "2026-07-01",
      });

    expect(response.status).toBe(403);
    expect(response.body.error.code).toBe("KYC_REQUIRED");
  });
});
