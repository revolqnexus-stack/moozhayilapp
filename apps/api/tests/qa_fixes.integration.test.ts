/**
 * QA-fixes integration test suite.
 *
 * Covers the six verified bugs fixed during QA validation:
 *   C-01 / C-03  — KYC step-up on approve/reject
 *   C-04         — Autopay dedup (unique constraint)
 *   C-05         — Idempotency claim-before-execute
 *   med-1        — OTP brute-force lock
 *   med-2        — Notification dedup
 *   pay capture  — POST /v1/payments/capture-checkout
 */

import request from "supertest";
import { createApp } from "../src/app";
import { prisma } from "../src/db/prisma";
import { clearRateLimitBucketsForTests } from "../src/middleware/rate_limit.middleware";

const app = createApp();

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

async function createTestUser() {
  return prisma.user.create({
    data: {
      phone: `+919${Math.floor(100000000 + Math.random() * 900000000)}`,
      lastActiveAt: new Date(),
    },
  });
}

async function loginUser(phone: string) {
  const otpRes = await request(app).post("/v1/auth/send-otp").send({ phone });
  const { otp_session_id } = otpRes.body as { otp_session_id: string };
  const verifyRes = await request(app)
    .post("/v1/auth/verify-otp")
    .send({ otp_session_id, otp: process.env.TEST_OTP_CODE ?? "123456" });
  return (verifyRes.body as { access_token: string }).access_token;
}

async function createAdminUser(role = "kyc_reviewer") {
  const { hashPassword } = await import("../src/utils/password");
  const hash = hashPassword("Admin@1234");
  return prisma.adminUser.create({
    data: {
      email: `qa_admin_${Date.now()}@test.internal`,
      name: "QA Admin",
      role: role as import("@prisma/client").AdminRole,
      passwordHash: hash,
    },
  });
}

async function adminLogin(email: string) {
  const res = await request(app)
    .post("/v1/admin/auth/login")
    .send({ email, password: "Admin@1234" });
  return (res.body as { access_token: string }).access_token;
}

async function adminStepUp(adminToken: string) {
  const res = await request(app)
    .post("/v1/admin/auth/step-up")
    .set("Authorization", `Bearer ${adminToken}`)
    .send({ password: "Admin@1234" });
  return (res.body as { step_up_token: string }).step_up_token;
}

// ---------------------------------------------------------------------------
// Setup / teardown
// ---------------------------------------------------------------------------

beforeAll(() => {
  process.env.NODE_ENV = "test";
  process.env.TEST_OTP_CODE = "123456";
});

beforeEach(() => {
  clearRateLimitBucketsForTests?.();
});

afterAll(async () => {
  await prisma.$disconnect();
});

// ---------------------------------------------------------------------------
// C-03: KYC approve/reject require step-up
// ---------------------------------------------------------------------------

describe("C-03: KYC step-up enforcement", () => {
  let adminToken: string;
  let stepUpToken: string;
  let targetUserId: string;

  beforeAll(async () => {
    await prisma.adminUser.deleteMany({ where: { email: { contains: "qa_admin_" } } });
    const admin = await createAdminUser("kyc_reviewer");
    adminToken = await adminLogin(admin.email);
    stepUpToken = await adminStepUp(adminToken);
    const user = await createTestUser();
    targetUserId = user.id;
  });

  afterAll(async () => {
    await prisma.adminUser.deleteMany({ where: { email: { contains: "qa_admin_" } } });
    await prisma.user.deleteMany({ where: { id: targetUserId } });
  });

  it("rejects KYC approve without step-up token", async () => {
    const res = await request(app)
      .post(`/v1/admin/kyc/${targetUserId}/approve`)
      .set("Authorization", `Bearer ${adminToken}`);

    expect(res.status).toBe(403);
  });

  it("rejects KYC reject without step-up token", async () => {
    const res = await request(app)
      .post(`/v1/admin/kyc/${targetUserId}/reject`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ reason: "Documents unclear" });

    expect(res.status).toBe(403);
  });

  it("allows KYC approve with valid step-up token", async () => {
    await prisma.user.update({
      where: { id: targetUserId },
      data: { kycStatus: "in_review" },
    });
    // Only aadhaar + selfie → basic_verified (no name match check needed).
    await prisma.kycDocument.upsert({
      where: { userId: targetUserId },
      create: {
        userId: targetUserId,
        aadhaarVerified: true,
        panVerified: false,
        selfieVerified: true,
      },
      update: {
        aadhaarVerified: true,
        panVerified: false,
        selfieVerified: true,
      },
    });

    const res = await request(app)
      .post(`/v1/admin/kyc/${targetUserId}/approve`)
      .set("Authorization", `Bearer ${adminToken}`)
      .set("x-admin-step-up", stepUpToken);

    expect(res.status).toBe(200);
  });
});

// ---------------------------------------------------------------------------
// C-04: Autopay dedup via unique constraint
// ---------------------------------------------------------------------------

describe("C-04: Contribution unique constraint prevents duplicates", () => {
  let goalId: string;
  let userId: string;

  beforeAll(async () => {
    const user = await createTestUser();
    userId = user.id;

    const rate = await prisma.goldRateHistory.findFirst({
      where: { purity: "k22", effectiveTo: null },
    });
    if (!rate) {
      await prisma.goldRateHistory.create({
        data: { purity: "k22", ratePerGramPaise: 550000, effectiveFrom: new Date(), source: "test" },
      });
    }

    const goal = await prisma.goal.create({
      data: {
        userId,
        name: "Test Goal",
        goalType: "other",
        status: "active",
        monthlyAmountPaise: 100000,
        durationMonths: 12,
        startDate: new Date(),
        nextContributionDate: new Date(),
        targetGrams: "2.0000",
      },
    });
    goalId = goal.id;
  });

  afterAll(async () => {
    await prisma.contribution.deleteMany({ where: { goalId } });
    await prisma.goal.deleteMany({ where: { id: goalId } });
    await prisma.user.deleteMany({ where: { id: userId } });
  });

  it("prevents two contributions with same goalId + month + type", async () => {
    const month = new Date("2026-06-01");

    await prisma.contribution.create({
      data: {
        goalId,
        userId,
        amountPaise: 100000,
        goldRatePerGramPaise: 600000,
        contributionMonth: month,
        type: "autopay",
        status: "scheduled",
      },
    });

    await expect(
      prisma.contribution.create({
        data: {
          goalId,
          userId,
          amountPaise: 100000,
          goldRatePerGramPaise: 600000,
          contributionMonth: month,
          type: "autopay",
          status: "scheduled",
        },
      }),
    ).rejects.toThrow();
  });
});

// ---------------------------------------------------------------------------
// C-05: Idempotency — second concurrent call gets cached result
// ---------------------------------------------------------------------------

describe("C-05: Idempotency key dedup", () => {
  let accessToken: string;
  let userId: string;

  beforeAll(async () => {
    const phone = `+919${Math.floor(100000000 + Math.random() * 900000000)}`;
    accessToken = await loginUser(phone);
    const userRow = await prisma.user.findFirst({ where: { phone } });
    userId = userRow!.id;

    // Grant KYC so goal creation passes the KYC gate.
    await prisma.user.update({
      where: { id: userId },
      data: { kycStatus: "basic_verified", kycVerifiedAt: new Date() },
    });

    // Ensure a gold rate exists for k22 (GOAL_ACCUMULATION_PURITY).
    const rate = await prisma.goldRateHistory.findFirst({
      where: { purity: "k22", effectiveTo: null },
    });
    if (!rate) {
      await prisma.goldRateHistory.create({
        data: {
          purity: "k22",
          ratePerGramPaise: 550000,
          effectiveFrom: new Date(),
          source: "test",
        },
      });
    }
  });

  afterAll(async () => {
    await prisma.idempotencyKey.deleteMany({
      where: { userId },
    });
    await prisma.goal.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
  });

  const goalBody = {
    scheme_type: "aura",
    goal_type: "other",
    name: "Idem Goal",
    monthly_amount_paise: 100000,
    duration_months: 11,
    start_date: new Date().toISOString().slice(0, 10),
  };

  it("returns same response for duplicate idempotency key", async () => {
    const key = `idem-test-${Date.now()}`;

    const r1 = await request(app)
      .post("/v1/goals")
      .set("Authorization", `Bearer ${accessToken}`)
      .set("Idempotency-Key", key)
      .send(goalBody);

    const r2 = await request(app)
      .post("/v1/goals")
      .set("Authorization", `Bearer ${accessToken}`)
      .set("Idempotency-Key", key)
      .send(goalBody);

    expect(r1.status).toBe(201);
    expect(r2.status).toBe(201);
    expect((r1.body as { goal: { id: string } }).goal.id).toBe(
      (r2.body as { goal: { id: string } }).goal.id,
    );
  });

  it("returns 409 when same key is reused with different body", async () => {
    const key = `idem-conflict-${Date.now()}`;

    await request(app)
      .post("/v1/goals")
      .set("Authorization", `Bearer ${accessToken}`)
      .set("Idempotency-Key", key)
      .send(goalBody);

    const r2 = await request(app)
      .post("/v1/goals")
      .set("Authorization", `Bearer ${accessToken}`)
      .set("Idempotency-Key", key)
      .send({ ...goalBody, name: "Different name" }); // different body

    expect(r2.status).toBe(409);
  });
});

// ---------------------------------------------------------------------------
// med-1: OTP brute-force lock after maxOtpAttempts
// ---------------------------------------------------------------------------

describe("med-1: OTP brute-force protection", () => {
  it("blocks session after 5 wrong OTPs", async () => {
    const phone = `+919${Math.floor(100000000 + Math.random() * 900000000)}`;
    const sendRes = await request(app).post("/v1/auth/send-otp").send({ phone });
    const { otp_session_id } = sendRes.body as { otp_session_id: string };

    for (let i = 0; i < 5; i++) {
      await request(app)
        .post("/v1/auth/verify-otp")
        .send({ otp_session_id, otp: "000000" });
    }

    const blocked = await request(app)
      .post("/v1/auth/verify-otp")
      .send({ otp_session_id, otp: "000000" });

    expect(blocked.status).toBe(429);
  });
});

// ---------------------------------------------------------------------------
// med-2: Notification dedup
// ---------------------------------------------------------------------------

describe("med-2: Notification idempotency key dedup", () => {
  let userId: string;

  beforeAll(async () => {
    const user = await createTestUser();
    userId = user.id;
  });

  afterAll(async () => {
    await prisma.notification.deleteMany({ where: { userId } });
    await prisma.notificationPreference.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
  });

  it("does not create duplicate notification with same idempotency key", async () => {
    const { notificationsService } = await import(
      "../src/modules/notifications/notifications.service"
    );

    const key = `order_confirmed:test-order-${Date.now()}`;

    await notificationsService.enqueue({
      userId,
      type: "order_confirmed",
      templateKey: "order_confirmed",
      variables: { order_number: "ORD001", total_display: "₹5,000" },
      deepLink: "/orders/test",
      idempotencyKey: key,
    });

    await notificationsService.enqueue({
      userId,
      type: "order_confirmed",
      templateKey: "order_confirmed",
      variables: { order_number: "ORD001", total_display: "₹5,000" },
      deepLink: "/orders/test",
      idempotencyKey: key,
    });

    const count = await prisma.notification.count({
      where: { idempotencyKey: key },
    });

    expect(count).toBe(1);
  });
});

// ---------------------------------------------------------------------------
// Payment capture-checkout endpoint
// ---------------------------------------------------------------------------

describe("POST /v1/payments/capture-checkout", () => {
  let accessToken: string;
  let paymentTxId: string;
  let userId: string;

  beforeAll(async () => {
    const phone = `+919${Math.floor(100000000 + Math.random() * 900000000)}`;
    accessToken = await loginUser(phone);

    const userRow = await prisma.user.findFirst({ where: { phone } });
    userId = userRow!.id;

    const tx = await prisma.paymentTransaction.create({
      data: {
        userId,
        type: "order_payment",
        status: "created",
        amountPaise: 50000,
        providerOrderId: "order_mock_test_123",
        idempotencyKey: `order_payment:cap_test_${Date.now()}`,
      },
    });
    paymentTxId = tx.id;
  });

  afterAll(async () => {
    await prisma.paymentTransaction.deleteMany({ where: { userId } });
    await prisma.user.deleteMany({ where: { id: userId } });
  });

  it("captures checkout when Cashfree order is paid in mock mode", async () => {
    const res = await request(app)
      .post("/v1/payments/capture-checkout")
      .set("Authorization", `Bearer ${accessToken}`)
      .send({
        payment_session_id: paymentTxId,
        cashfree_order_id: "order_mock_test_123",
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  it("returns 422 for missing required fields", async () => {
    const res = await request(app)
      .post("/v1/payments/capture-checkout")
      .set("Authorization", `Bearer ${accessToken}`)
      .send({ payment_session_id: paymentTxId });

    expect(res.status).toBe(422);
  });
});
