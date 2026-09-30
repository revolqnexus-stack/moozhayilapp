import request from "supertest";
import { createApp } from "../src/app";

describe("Razorpay web checkout API", () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = {
      ...originalEnv,
      NODE_ENV: "test",
      RAZORPAY_KEY_ID: "rzp_test_example",
      RAZORPAY_KEY_SECRET: "test_secret_key_value",
    };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it("rejects create-order below minimum amount", async () => {
    const app = createApp();
    const res = await request(app)
      .post("/api/create-order")
      .send({ amount: 50 });

    expect(res.status).toBe(400);
  });

  it("rejects verify-payment with missing fields", async () => {
    const app = createApp();
    const res = await request(app).post("/api/verify-payment").send({});

    expect(res.status).toBe(400);
  });

  it("rejects verify-payment when signature does not match", async () => {
    const app = createApp();
    const res = await request(app).post("/api/verify-payment").send({
      razorpay_payment_id: "pay_test",
      razorpay_order_id: "order_test",
      razorpay_signature: "invalid_signature",
    });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });
});
