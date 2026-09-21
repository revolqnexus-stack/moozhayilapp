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
import { PRICE_VALIDITY_MS } from "../src/config/price.constants";

async function cleanTables() {
  await prisma.priceQuote.deleteMany();
  await prisma.webhookEvent.deleteMany();
  await prisma.idempotencyKey.deleteMany();
  await prisma.inventoryReservation.deleteMany();
  await prisma.orderItem.deleteMany();
  await prisma.order.deleteMany();
  await prisma.paymentTransaction.deleteMany();
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
    data: { name: "Bangles", slug: "bangles-quote" },
  });
  await prisma.goldRateHistory.create({
    data: {
      purity: "k22",
      ratePerGramPaise: 624000,
      effectiveFrom: new Date("2026-06-26T04:30:00Z"),
      source: "test",
    },
  });
  return prisma.product.create({
    data: {
      sku: "MGD-QUOTE-001",
      name: "Quote Bangle",
      categoryId: category.id,
      purity: "k22",
      weightGrams: "1.0000",
      makingChargePct: "12.00",
      stockQuantity: 5,
      isPublished: true,
    },
  });
}

describe("Price quotes (Fix 1)", () => {
  let app: ReturnType<typeof createApp>;

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
  });

  afterAll(async () => {
    await cleanTables();
    await prisma.$disconnect();
  });

  it("issues quote with server_time and price_valid_until", async () => {
    const product = await seedCatalog();
    const auth = await signIn(app, "+919876543300");

    const response = await request(app)
      .post("/v1/quotes")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ items: [{ product_id: product.id, quantity: 1 }] });

    expect(response.status).toBe(201);
    expect(response.body.quote_id).toBeTruthy();
    expect(response.body.server_time).toBeTruthy();
    expect(response.body.price_valid_until).toBeTruthy();
    expect(response.body.total_paise).toBeGreaterThan(0);
  });

  it("returns 409 PRICE_EXPIRED with fresh quote on expired order-create", async () => {
    const product = await seedCatalog();
    const auth = await signIn(app, "+919876543301");
    await prisma.user.update({
      where: { id: auth.userId },
      data: { kycStatus: "basic_verified" },
    });
    const address = await prisma.address.create({
      data: {
        userId: auth.userId,
        fullName: "Quote User",
        phone: "+919876543301",
        line1: "12 Temple Road",
        city: "Thrissur",
        state: "Kerala",
        pincode: "680001",
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

    const quoteResponse = await request(app)
      .post("/v1/quotes")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ items: [{ product_id: product.id, quantity: 1 }] });

    const quoteId = quoteResponse.body.quote_id as string;

    await prisma.priceQuote.update({
      where: { id: quoteId },
      data: {
        validUntil: new Date(Date.now() - PRICE_VALIDITY_MS),
      },
    });

    const orderResponse = await request(app)
      .post("/v1/orders")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .set("Idempotency-Key", "quote-expired")
      .send({
        quote_id: quoteId,
        items: [{ product_id: product.id, quantity: 1 }],
        delivery_address_id: address.id,
        payment_method: "cod",
      });

    expect(orderResponse.status).toBe(409);
    expect(orderResponse.body.error.code).toBe("PRICE_EXPIRED");
    expect(orderResponse.body.error.details.fresh_quote).toBeTruthy();
  });

  it("invalidates quote when cart changes", async () => {
    const product = await seedCatalog();
    const auth = await signIn(app, "+919876543302");

    const quoteResponse = await request(app)
      .post("/v1/quotes/from-cart")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({});

    expect(quoteResponse.status).toBe(422);

    await request(app)
      .post("/v1/cart/items")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ product_id: product.id, quantity: 1 });

    const quoteAfterAdd = await request(app)
      .post("/v1/quotes/from-cart")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({});

    expect(quoteAfterAdd.status).toBe(201);
    const firstQuoteId = quoteAfterAdd.body.quote_id as string;

    await request(app)
      .delete(`/v1/cart/items/${product.id}`)
      .set("Authorization", `Bearer ${auth.accessToken}`);

    const stored = await prisma.priceQuote.findUniqueOrThrow({
      where: { id: firstQuoteId },
    });
    expect(stored.status).toBe("superseded");
  });
});
