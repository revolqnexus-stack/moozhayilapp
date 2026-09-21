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
import { paymentProviderClient } from "../src/modules/payments/payment_provider.client";
async function createQuote(
  app: ReturnType<typeof createApp>,
  accessToken: string,
  productId: string,
) {
  const response = await request(app)
    .post("/v1/quotes")
    .set("Authorization", `Bearer ${accessToken}`)
    .send({ items: [{ product_id: productId, quantity: 1 }] });
  expect(response.status).toBe(201);
  return response.body.quote_id as string;
}

async function cleanTables() {
  await prisma.priceQuote.deleteMany();
  await prisma.webhookEvent.deleteMany();
  await prisma.idempotencyKey.deleteMany();
  await prisma.inventoryReservation.deleteMany();
  await prisma.orderItem.deleteMany();
  await prisma.order.deleteMany();
  await prisma.paymentTransaction.deleteMany();
  await prisma.goldBalanceSnapshot.deleteMany();
  await prisma.goldLedgerEntry.deleteMany();
  await prisma.contribution.deleteMany();
  await prisma.goal.deleteMany();
  await prisma.cartItem.deleteMany();
  await prisma.address.deleteMany();
  await prisma.serviceablePincode.deleteMany();
  await prisma.productOccasionTag.deleteMany();
  await prisma.productImage.deleteMany();
  await prisma.product.deleteMany();
  await prisma.goldRateHistory.deleteMany();
  await prisma.category.deleteMany();
  await prisma.authSession.deleteMany();
  await prisma.otpSession.deleteMany();
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
      sku: "MGD-KYC-001",
      name: "Temple Bangle",
      categoryId: category.id,
      purity: "k22",
      weightGrams: "1.0000",
      makingChargePct: "12.00",
      stockQuantity: 5,
      isPublished: true,
    },
  });
  await prisma.serviceablePincode.create({
    data: {
      pincode: "680001",
      city: "Thrissur",
      state: "Kerala",
      serviceable: true,
      estimatedDeliveryDays: 3,
      pickupAvailable: true,
    },
  });
  return product;
}

async function seedHeavyProduct(categoryId: string) {
  return prisma.product.create({
    data: {
      sku: "MGD-KYC-HEAVY",
      name: "Heavy Necklace",
      categoryId,
      purity: "k22",
      weightGrams: "80.0000",
      makingChargePct: "12.00",
      stockQuantity: 2,
      isPublished: true,
    },
  });
}

describe("KYC enforcement (route-level)", () => {
  let app: ReturnType<typeof createApp>;
  let createOrderSpy: jest.SpiedFunction<
    typeof paymentProviderClient.createOrder
  >;

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
    createOrderSpy = jest
      .spyOn(paymentProviderClient, "createOrder")
      .mockResolvedValue({
        providerOrderId: "rzp_test_order",
        paymentSessionId: "sess_test",
        amountPaise: 100,
      });
  });

  afterEach(() => {
    createOrderSpy?.mockRestore();
  });

  afterAll(async () => {
    await cleanTables();
    await prisma.$disconnect();
  });

  describe("POST /v1/orders with gold_balance (redeemWithGold)", () => {
    for (const status of ["not_started", "in_review", "rejected"] as const) {
      it(`returns 403 KYC_REQUIRED for ${status} before side effects`, async () => {
        const product = await seedCatalog();
        const auth = await signIn(app, "+919876543210");
        await prisma.user.update({
          where: { id: auth.userId },
          data: { kycStatus: status },
        });
        await prisma.goldLedgerEntry.create({
          data: {
            userId: auth.userId,
            entryType: "contribution_credit",
            status: "posted",
            gramsDelta: "5.0000",
            amountPaise: 3120000,
            goldRatePerGramPaise: 624000,
            sourceType: "contribution",
            sourceId: crypto.randomUUID(),
            correlationId: crypto.randomUUID(),
            idempotencyKey: `seed:${auth.userId}`,
            postedAt: new Date(),
          },
        });
        const address = await prisma.address.create({
          data: {
            userId: auth.userId,
            fullName: "Test User",
            phone: "+919876543210",
            line1: "12 Temple Road",
            city: "Thrissur",
            state: "Kerala",
            pincode: "680001",
          },
        });

        const quoteId = await createQuote(app, auth.accessToken, product.id);

        const response = await request(app)
          .post("/v1/orders")
          .set("Authorization", `Bearer ${auth.accessToken}`)
          .set("Idempotency-Key", `kyc-block-${status}`)
          .send({
            quote_id: quoteId,
            items: [{ product_id: product.id, quantity: 1 }],
            delivery_address_id: address.id,
            payment_method: "gold_balance",
          });

        expect(response.status).toBe(403);
        expect(response.body.error.code).toBe("KYC_REQUIRED");
        expect(response.body.error.details.kyc_status).toBe(status);

        expect(await prisma.order.count()).toBe(0);
        expect(await prisma.inventoryReservation.count()).toBe(0);
        expect(
          await prisma.goldLedgerEntry.count({
            where: { entryType: "redemption_debit" },
          }),
        ).toBe(0);
        expect(createOrderSpy).not.toHaveBeenCalled();
      });
    }

    it("does not return KYC_REQUIRED for basic_verified redemption intent", async () => {
      const product = await seedCatalog();
      const auth = await signIn(app, "+919876543211");
      await prisma.user.update({
        where: { id: auth.userId },
        data: { kycStatus: "basic_verified" },
      });
      await prisma.goldLedgerEntry.create({
        data: {
          userId: auth.userId,
          entryType: "contribution_credit",
          status: "posted",
          gramsDelta: "5.0000",
          amountPaise: 3120000,
          goldRatePerGramPaise: 624000,
          sourceType: "contribution",
          sourceId: crypto.randomUUID(),
          correlationId: crypto.randomUUID(),
          idempotencyKey: `seed2:${auth.userId}`,
          postedAt: new Date(),
        },
      });
      const address = await prisma.address.create({
        data: {
          userId: auth.userId,
          fullName: "Verified User",
          phone: "+919876543211",
          line1: "12 Temple Road",
          city: "Thrissur",
          state: "Kerala",
          pincode: "680001",
        },
      });

      const quoteId = await createQuote(app, auth.accessToken, product.id);

      const response = await request(app)
        .post("/v1/orders")
        .set("Authorization", `Bearer ${auth.accessToken}`)
        .set("Idempotency-Key", "kyc-allow-gold")
        .send({
          quote_id: quoteId,
          items: [{ product_id: product.id, quantity: 1 }],
          delivery_address_id: address.id,
          payment_method: "gold_balance",
        });

      expect(response.status).not.toBe(403);
      expect(response.body?.error?.code).not.toBe("KYC_REQUIRED");
    });
  });

  describe("POST /v1/goals/:id/contribute", () => {
    it("returns 403 for not_started before contribution row is created", async () => {
      await seedCatalog();
      const auth = await signIn(app, "+919876543212");
      await prisma.user.update({
        where: { id: auth.userId },
        data: { kycStatus: "basic_verified" },
      });
      const goal = await prisma.goal.create({
        data: {
          userId: auth.userId,
          name: "Test Goal",
          goalType: "wedding",
          schemeType: "aura",
          status: "active",
          monthlyAmountPaise: 300000,
          durationMonths: 11,
          startDate: new Date("2026-07-01"),
          nextContributionDate: new Date("2026-07-01"),
        },
      });
      await prisma.user.update({
        where: { id: auth.userId },
        data: { kycStatus: "not_started" },
      });

      const response = await request(app)
        .post(`/v1/goals/${goal.id}/contribute`)
        .set("Authorization", `Bearer ${auth.accessToken}`)
        .set("Idempotency-Key", "contrib-kyc-block")
        .send({ amount_paise: 300000 });

      expect(response.status).toBe(403);
      expect(await prisma.contribution.count()).toBe(0);
      expect(createOrderSpy).not.toHaveBeenCalled();
    });
  });

  describe("order KYC threshold (gross totalPaise, strictly > ₹50,000)", () => {
    it("blocks not_started above threshold before order creation", async () => {
      const product = await seedCatalog();
      const heavy = await seedHeavyProduct(product.categoryId);
      const auth = await signIn(app, "+919876543213");
      await prisma.user.update({
        where: { id: auth.userId },
        data: { kycStatus: "not_started" },
      });
      const address = await prisma.address.create({
        data: {
          userId: auth.userId,
          fullName: "High Value",
          phone: "+919876543213",
          line1: "12 Temple Road",
          city: "Thrissur",
          state: "Kerala",
          pincode: "680001",
        },
      });

      const quoteId = await createQuote(app, auth.accessToken, heavy.id);

      const response = await request(app)
        .post("/v1/orders")
        .set("Authorization", `Bearer ${auth.accessToken}`)
        .set("Idempotency-Key", "kyc-high-value")
        .send({
          quote_id: quoteId,
          items: [{ product_id: heavy.id, quantity: 1 }],
          delivery_address_id: address.id,
          payment_method: "upi",
        });

      expect(response.status).toBe(403);
      expect(response.body.error.code).toBe("KYC_REQUIRED");
      expect(await prisma.order.count()).toBe(0);
      expect(createOrderSpy).not.toHaveBeenCalled();
    });
  });

  describe("payment webhook is not KYC-gated", () => {
    it("accepts signed webhook without user auth or KYC context", async () => {
      const payload = {
        id: "evt_kyc_webhook_no_auth",
        event: "payment.captured",
        payload: {
          payment: {
            entity: {
              order_id: "mock_order_no_kyc_gate",
              id: "mock_pay_no_kyc_gate",
              status: "captured",
            },
          },
        },
      };
      const raw = JSON.stringify(payload);

      const response = await request(app)
        .post("/v1/webhooks/payment")
        .set("Content-Type", "application/json")
        .set(
          "x-razorpay-signature",
          process.env.RAZORPAY_WEBHOOK_SECRET ?? "mock_valid_signature",
        )
        .send(raw);

      expect(response.status).toBe(200);
      expect(response.body.received).toBe(true);
      expect(response.body).not.toHaveProperty("error");
    });
  });

  describe("in-flight scheme exposure", () => {
    it("reports active goals owned by non-verified users", async () => {
      await seedCatalog();
      const verified = await signIn(app, "+919876543214");
      await prisma.user.update({
        where: { id: verified.userId },
        data: { kycStatus: "basic_verified" },
      });
      await prisma.goal.create({
        data: {
          userId: verified.userId,
          name: "Verified goal",
          goalType: "wedding",
          schemeType: "aura",
          status: "active",
          monthlyAmountPaise: 300000,
          durationMonths: 11,
          startDate: new Date("2026-07-01"),
          nextContributionDate: new Date("2026-07-01"),
        },
      });

      const unverified = await signIn(app, "+919876543215");
      await prisma.user.update({
        where: { id: unverified.userId },
        data: { kycStatus: "rejected" },
      });
      await prisma.goal.create({
        data: {
          userId: unverified.userId,
          name: "Rejected mid-scheme",
          goalType: "wedding",
          schemeType: "aura",
          status: "active",
          monthlyAmountPaise: 300000,
          durationMonths: 11,
          startDate: new Date("2026-06-01"),
          nextContributionDate: new Date("2026-07-01"),
        },
      });

      const count = await prisma.goal.count({
        where: {
          status: "active",
          deletedAt: null,
          user: {
            kycStatus: { notIn: ["basic_verified", "enhanced_verified"] },
          },
        },
      });
      expect(count).toBe(1);
    });
  });
});
