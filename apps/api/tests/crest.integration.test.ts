import dotenv from "dotenv";
import request from "supertest";

dotenv.config();

function stripEmptyEnv(keys: string[]) {
  for (const key of keys) {
    if (process.env[key] === "") {
      delete process.env[key];
    }
  }
}

import { createApp } from "../src/app";
import { prisma } from "../src/db/prisma";
import { clearRateLimitBucketsForTests } from "../src/middleware/rate_limit.middleware";
import { CREST_DURATION_MONTHS } from "../src/config/crest.constants";
import { goldLedgerService } from "../src/modules/gold_ledger/gold_ledger.service";
import { calculateGramsFromPaise } from "../src/utils/gold";

async function cleanTables() {
  await prisma.idempotencyKey.deleteMany();
  await prisma.goldLedgerEntry.deleteMany();
  await prisma.contribution.deleteMany();
  await prisma.goal.deleteMany();
  await prisma.goldRateHistory.deleteMany();
  await prisma.authSession.deleteMany();
  await prisma.otpSession.deleteMany();
  await prisma.user.deleteMany();
}

async function signIn(app: ReturnType<typeof createApp>, phone: string) {
  const sendResponse = await request(app).post("/v1/auth/send-otp").send({ phone });
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

describe("CREST gold-weight lock integration", () => {
  let app: ReturnType<typeof createApp>;
  const enrollRatePaise = 774_000;
  const laterRatePaise = 800_000;
  const advancePaise = 5_000_000;

  beforeAll(() => {
    stripEmptyEnv([
      "KYC_PROVIDER_BASE_URL",
      "KYC_PROVIDER_API_KEY",
      "S3_ENDPOINT",
      "S3_BUCKET",
      "S3_ACCESS_KEY_ID",
      "S3_SECRET_ACCESS_KEY",
      "S3_PUBLIC_BASE_URL",
      "MSG91_AUTH_KEY",
      "MSG91_OTP_TEMPLATE_ID",
      "CASHFREE_APP_ID",
      "CASHFREE_SECRET_KEY",
      "FIREBASE_PROJECT_ID",
      "FIREBASE_CLIENT_EMAIL",
      "FIREBASE_PRIVATE_KEY",
      "SENTRY_DSN",
    ]);
    process.env.NODE_ENV = "test";
    process.env.TEST_OTP_CODE = "123456";
    process.env.PAYMENT_PROVIDER_MODE = "mock";
    process.env.RAZORPAY_WEBHOOK_SECRET = "mock_webhook_secret_for_local_dev";
    app = createApp();
  });

  beforeEach(async () => {
    clearRateLimitBucketsForTests();
    await cleanTables();
    await prisma.goldRateHistory.create({
      data: {
        purity: "k22",
        ratePerGramPaise: enrollRatePaise,
        effectiveFrom: new Date("2026-01-01T00:00:00Z"),
        source: "test-enroll",
      },
    });
  });

  afterAll(async () => {
    await cleanTables();
    await prisma.$disconnect();
  });

  it("stores booking rate on enroll and credits locked grams after rate change", async () => {
    const auth = await signIn(app, "+919876543220");
    await verifyUser(auth.userId);

    const created = await request(app)
      .post("/v1/goals")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .set("Idempotency-Key", "crest-enroll")
      .send({
        scheme_type: "crest",
        goal_type: "wedding",
        name: "Crest Advance",
        monthly_amount_paise: advancePaise,
        duration_months: CREST_DURATION_MONTHS,
        start_date: "2026-07-01",
      });

    expect(created.status).toBe(201);
    const goalId = created.body.goal.id as string;
    await prisma.goal.update({
      where: { id: goalId },
      data: { bonusEligible: false },
    });
    const expectedLocked = calculateGramsFromPaise(
      advancePaise,
      enrollRatePaise,
    ).toFixed(4);

    expect(created.body.goal.target_grams).toBe(expectedLocked);

    const goalAfterCreate = await prisma.goal.findUniqueOrThrow({
      where: { id: goalId },
    });
    expect(goalAfterCreate.bookingRatePaisePerGram).toBe(enrollRatePaise);

    await prisma.goldRateHistory.updateMany({
      where: { purity: "k22", effectiveTo: null },
      data: { effectiveTo: new Date("2026-07-02T00:00:00Z") },
    });
    await prisma.goldRateHistory.create({
      data: {
        purity: "k22",
        ratePerGramPaise: laterRatePaise,
        effectiveFrom: new Date("2026-07-02T00:00:00Z"),
        source: "test-later",
      },
    });

    const paid = await request(app)
      .post(`/v1/goals/${goalId}/contribute`)
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .set("Idempotency-Key", "crest-pay")
      .send({ amount_paise: advancePaise });

    expect(paid.status).toBe(200);

    const contribution = await prisma.contribution.findFirstOrThrow({
      where: { goalId, status: "completed" },
    });
    expect(contribution.goldRatePerGramPaise).toBe(enrollRatePaise);
    expect(String(contribution.gramsCredited)).toBe(expectedLocked);

    const ledgerGrams = await goldLedgerService.getGoalCreditedGrams(goalId);
    expect(ledgerGrams.toFixed(4)).toBe(expectedLocked);
  });

  it("legacy goal without bookingRate still credits locked targetGrams when set", async () => {
    const auth = await signIn(app, "+919876543221");
    await verifyUser(auth.userId);

    const locked = calculateGramsFromPaise(advancePaise, enrollRatePaise).toFixed(
      4,
    );

    const goal = await prisma.goal.create({
      data: {
        userId: auth.userId,
        name: "Legacy Crest",
        schemeType: "crest",
        goalType: "wedding",
        monthlyAmountPaise: advancePaise,
        durationMonths: CREST_DURATION_MONTHS,
        startDate: new Date("2026-07-01T00:00:00Z"),
        nextContributionDate: new Date("2026-07-01T00:00:00Z"),
        targetGrams: locked,
        bookingRatePaisePerGram: null,
        bonusEligible: false,
      },
    });

    await prisma.goldRateHistory.updateMany({
      where: { purity: "k22", effectiveTo: null },
      data: { effectiveTo: new Date("2026-07-02T00:00:00Z") },
    });
    await prisma.goldRateHistory.create({
      data: {
        purity: "k22",
        ratePerGramPaise: laterRatePaise,
        effectiveFrom: new Date("2026-07-02T00:00:00Z"),
        source: "test-later-legacy",
      },
    });

    const paid = await request(app)
      .post(`/v1/goals/${goal.id}/contribute`)
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .set("Idempotency-Key", "crest-legacy-pay")
      .send({ amount_paise: advancePaise });

    expect(paid.status).toBe(200);

    const contribution = await prisma.contribution.findFirstOrThrow({
      where: { goalId: goal.id, status: "completed" },
    });
    expect(contribution.goldRatePerGramPaise).toBe(laterRatePaise);
    expect(String(contribution.gramsCredited)).toBe(locked);

    const ledgerGrams = await goldLedgerService.getGoalCreditedGrams(goal.id);
    expect(ledgerGrams.toFixed(4)).toBe(locked);
  });
});
