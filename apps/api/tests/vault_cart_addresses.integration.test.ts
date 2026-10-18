import request from "supertest";
import { createApp } from "../src/app";
import { prisma } from "../src/db/prisma";
import { clearRateLimitBucketsForTests } from "../src/middleware/rate_limit.middleware";

async function cleanPhase5Tables() {
  await prisma.cartItem.deleteMany();
  await prisma.dreamVaultItem.deleteMany();
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

async function signIn(phone: string) {
  const app = createApp();
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

async function seedProduct() {
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
      sku: "MGD-P5-001",
      name: "Temple Bangle",
      categoryId: category.id,
      purity: "k22",
      weightGrams: "13.6000",
      makingChargePct: "12.00",
      stockQuantity: 2,
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

describe("Phase 5 vault cart and addresses", () => {
  const app = createApp();

  beforeAll(() => {
    process.env.NODE_ENV = "test";
    process.env.TEST_OTP_CODE = "123456";
  });

  beforeEach(async () => {
    clearRateLimitBucketsForTests();
    await cleanPhase5Tables();
  });

  afterAll(async () => {
    await cleanPhase5Tables();
    await prisma.$disconnect();
  });

  it("adds and removes Dream Vault items with current prices", async () => {
    const product = await seedProduct();
    const auth = await signIn("+919876543210");

    const addResponse = await request(app)
      .post("/v1/vault")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ product_id: product.id });

    expect(addResponse.status).toBe(201);
    expect(addResponse.body.vault_item.product.price.total_paise).toBeGreaterThan(0);
    expect(addResponse.body.goal_suggestion.suggested_monthly_paise).toBeGreaterThan(0);

    const listResponse = await request(app)
      .get("/v1/vault")
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(listResponse.status).toBe(200);
    expect(listResponse.body.count).toBe(1);
    expect(listResponse.body.items[0].product.name).toBe("Temple Bangle");

    const duplicate = await request(app)
      .post("/v1/vault")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ product_id: product.id });

    expect(duplicate.status).toBe(409);

    const removeResponse = await request(app)
      .delete(`/v1/vault/${listResponse.body.items[0].id}`)
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(removeResponse.status).toBe(200);
    expect(removeResponse.body.success).toBe(true);
  });

  it("removes Dream Vault items by product id and treats stale item ids as success", async () => {
    const product = await seedProduct();
    const auth = await signIn("+919876543213");

    const addResponse = await request(app)
      .post("/v1/vault")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ product_id: product.id });

    expect(addResponse.status).toBe(201);

    const removeByProduct = await request(app)
      .delete(`/v1/vault/products/${product.id}`)
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(removeByProduct.status).toBe(200);
    expect(removeByProduct.body.success).toBe(true);

    const staleItemId = addResponse.body.vault_item.id as string;
    const removeStale = await request(app)
      .delete(`/v1/vault/${staleItemId}`)
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(removeStale.status).toBe(200);
    expect(removeStale.body.success).toBe(true);
  });

  it("supports guest handoff by restoring a previously removed vault item", async () => {
    const product = await seedProduct();
    const auth = await signIn("+919876543211");

    const first = await request(app)
      .post("/v1/vault")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ product_id: product.id });

    await request(app)
      .delete(`/v1/vault/${first.body.vault_item.id}`)
      .set("Authorization", `Bearer ${auth.accessToken}`);

    const restored = await request(app)
      .post("/v1/vault")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ product_id: product.id });

    expect(restored.status).toBe(201);
    expect(restored.body.vault_item.product.id).toBe(product.id);
  });

  it("returns cart with current prices and handles out of stock", async () => {
    const product = await seedProduct();
    const auth = await signIn("+919876543212");

    const addResponse = await request(app)
      .post("/v1/cart/items")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ product_id: product.id, quantity: 1 });

    expect(addResponse.status).toBe(201);
    expect(addResponse.body.items).toHaveLength(1);
    expect(addResponse.body.subtotal_paise).toBeGreaterThan(0);

    await prisma.product.update({
      where: { id: product.id },
      data: { stockQuantity: 0 },
    });

    const cartResponse = await request(app)
      .get("/v1/cart")
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(cartResponse.status).toBe(200);
    expect(cartResponse.body.items[0].is_available).toBe(false);
    expect(cartResponse.body.items[0].unavailable_reason).toBe("Out of stock");
  });

  it("validates serviceable pincodes and creates addresses", async () => {
    await seedProduct();
    const auth = await signIn("+919876543213");

    const invalidPincode = await request(app)
      .post("/v1/addresses/validate-pincode")
      .send({ pincode: "999999" });

    expect(invalidPincode.status).toBe(200);
    expect(invalidPincode.body.serviceable).toBe(false);

    const validPincode = await request(app)
      .post("/v1/addresses/validate-pincode")
      .send({ pincode: "680001" });

    expect(validPincode.body.serviceable).toBe(true);
    expect(validPincode.body.city).toBe("Thrissur");

    const createResponse = await request(app)
      .post("/v1/addresses")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({
        label: "Home",
        full_name: "Priya Menon",
        phone: "+919876543210",
        line1: "123 MG Road",
        city: "Thrissur",
        state: "Kerala",
        pincode: "680001",
      });

    expect(createResponse.status).toBe(201);
    expect(createResponse.body.is_default).toBe(true);

    const rejectResponse = await request(app)
      .post("/v1/addresses")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({
        full_name: "Priya Menon",
        phone: "+919876543210",
        line1: "123 MG Road",
        city: "Unknown",
        state: "Unknown",
        pincode: "999999",
      });

    expect(rejectResponse.status).toBe(400);
  });
});
