import dotenv from "dotenv";
import request from "supertest";
import { createApp } from "../src/app";
import { prisma } from "../src/db/prisma";
import { clearRateLimitBucketsForTests } from "../src/middleware/rate_limit.middleware";

dotenv.config();

for (const [key, value] of Object.entries(process.env)) {
  if (value === "") {
    delete process.env[key];
  }
}

async function cleanIdentityTables() {
  await prisma.authSession.deleteMany();
  await prisma.otpSession.deleteMany();
  await prisma.user.deleteMany();
}

describe("Auth mock SMS OTP (staging behaviour)", () => {
  const previousNodeEnv = process.env.NODE_ENV;
  const previousSmsMode = process.env.SMS_PROVIDER_MODE;
  const previousTestOtp = process.env.TEST_OTP_CODE;

  beforeAll(() => {
    process.env.NODE_ENV = "development";
    process.env.SMS_PROVIDER_MODE = "mock";
    delete process.env.TEST_OTP_CODE;
  });

  afterAll(async () => {
    process.env.NODE_ENV = previousNodeEnv;
    process.env.SMS_PROVIDER_MODE = previousSmsMode;
    if (previousTestOtp === undefined) {
      delete process.env.TEST_OTP_CODE;
    } else {
      process.env.TEST_OTP_CODE = previousTestOtp;
    }
    await cleanIdentityTables();
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    clearRateLimitBucketsForTests();
    await cleanIdentityTables();
  });

  const app = createApp();

  it("accepts fixed mock OTP 123456 when SMS_PROVIDER_MODE is mock", async () => {
    const sendResponse = await request(app)
      .post("/v1/auth/send-otp")
      .send({ phone: "+919876543210" });

    expect(sendResponse.status).toBe(200);

    const verifyResponse = await request(app)
      .post("/v1/auth/verify-otp")
      .send({
        otp_session_id: sendResponse.body.otp_session_id,
        otp: "123456",
      });

    expect(verifyResponse.status).toBe(200);
    expect(verifyResponse.body.access_token).toEqual(expect.any(String));
    expect(verifyResponse.body.user.phone).toBe("+919876543210");
  });

  it("rejects an incorrect OTP in mock mode", async () => {
    const sendResponse = await request(app)
      .post("/v1/auth/send-otp")
      .send({ phone: "+919876543211" });

    expect(sendResponse.status).toBe(200);

    const verifyResponse = await request(app)
      .post("/v1/auth/verify-otp")
      .send({
        otp_session_id: sendResponse.body.otp_session_id,
        otp: "000000",
      });

    expect(verifyResponse.status).toBe(401);
    expect(verifyResponse.body.error).toMatchObject({
      code: "UNAUTHORIZED",
      message: "Incorrect OTP",
    });
  });
});
