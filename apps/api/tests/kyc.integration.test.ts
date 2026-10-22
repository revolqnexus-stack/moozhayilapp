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
import {
  signAdminStepUpToken,
  signAdminToken,
} from "../src/modules/admin/admin.middleware";
import { clearRateLimitBucketsForTests } from "../src/middleware/rate_limit.middleware";

async function cleanKycTables() {
  await prisma.auditLog.deleteMany();
  await prisma.kycAadhaarSession.deleteMany();
  await prisma.kycDocument.deleteMany();
  await prisma.adminUser.deleteMany();
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

async function seedAdmin() {
  return prisma.adminUser.create({
    data: {
      email: "kyc.reviewer@moozhayil.com",
      name: "KYC Reviewer",
      role: "kyc_reviewer",
    },
  });
}

function adminAuthHeaders(adminId: string, role: import("@prisma/client").AdminRole) {
  return {
    Authorization: `Bearer ${signAdminToken(adminId, role)}`,
    "x-admin-step-up": signAdminStepUpToken(adminId),
  };
}

describe("Phase 6 KYC and admin review", () => {
  let app: ReturnType<typeof createApp>;

  beforeAll(() => {
    stripEmptyEnv([
      "KYC_PROVIDER_BASE_URL",
      "KYC_PROVIDER_API_KEY",
      "STAMPMITRA_API_KEY",
      "S3_ENDPOINT",
      "S3_BUCKET",
      "S3_ACCESS_KEY_ID",
      "S3_SECRET_ACCESS_KEY",
      "S3_PUBLIC_BASE_URL",
      "MSG91_AUTH_KEY",
      "MSG91_OTP_TEMPLATE_ID",
      "RAZORPAY_WEBHOOK_SECRET",
      "CASHFREE_APP_ID",
      "CASHFREE_SECRET_KEY",
      "FIREBASE_PROJECT_ID",
      "FIREBASE_CLIENT_EMAIL",
      "FIREBASE_PRIVATE_KEY",
      "SENTRY_DSN",
    ]);
    process.env.NODE_ENV = "test";
    process.env.TEST_OTP_CODE = "123456";
    process.env.TEST_KYC_AADHAAR_OTP = "654321";
    process.env.KYC_PROVIDER_MODE = "mock";
    app = createApp();
  });

  beforeEach(async () => {
    clearRateLimitBucketsForTests();
    await cleanKycTables();
  });

  afterAll(async () => {
    await cleanKycTables();
    await prisma.$disconnect();
  });

  it("completes basic KYC flow and admin approval", async () => {
    const auth = await signIn(app, "+919876543210");
    const admin = await seedAdmin();
    const adminHeaders = adminAuthHeaders(admin.id, admin.role);

    const sendOtp = await request(app)
      .post("/v1/kyc/aadhaar/send-otp")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ aadhaar_number: "123456789012" });

    expect(sendOtp.status).toBe(200);
    expect(sendOtp.body.session_id).toEqual(expect.any(String));

    const verifyOtp = await request(app)
      .post("/v1/kyc/aadhaar/verify")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({
        session_id: sendOtp.body.session_id,
        otp: "654321",
      });

    expect(verifyOtp.status).toBe(200);
    expect(verifyOtp.body.verified).toBe(true);

    const selfie = await request(app)
      .post("/v1/kyc/selfie")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .attach("selfie", Buffer.from("fake-image-bytes"), {
        filename: "selfie.jpg",
        contentType: "image/jpeg",
      });

    expect(selfie.status).toBe(200);
    expect(selfie.body.uploaded).toBe(true);

    const submit = await request(app)
      .post("/v1/kyc/submit")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({});

    expect(submit.status).toBe(200);
    expect(submit.body.kyc_status).toBe("in_review");

    const approve = await request(app)
      .post(`/v1/admin/kyc/${auth.userId}/approve`)
      .set(adminHeaders)
      .send({});

    expect(approve.status).toBe(200);
    expect(approve.body.kyc_status).toBe("basic_verified");

    const status = await request(app)
      .get("/v1/kyc/status")
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(status.status).toBe(200);
    expect(status.body.kyc_status).toBe("basic_verified");

    const auditLogs = await prisma.auditLog.findMany({
      where: { entityId: auth.userId },
    });

    expect(auditLogs.some((log) => log.action === "kyc_submitted")).toBe(true);
    expect(auditLogs.some((log) => log.action === "kyc_approved")).toBe(true);
    expect(JSON.stringify(auditLogs)).not.toContain("123456789012");
  });

  it("approves enhanced tier when Aadhaar and PAN names match", async () => {
    const auth = await signIn(app, "+919876543211");
    const admin = await seedAdmin();
    const adminHeaders = adminAuthHeaders(admin.id, admin.role);

    const sendOtp = await request(app)
      .post("/v1/kyc/aadhaar/send-otp")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ aadhaar_number: "987654321098" });

    await request(app)
      .post("/v1/kyc/aadhaar/verify")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ session_id: sendOtp.body.session_id, otp: "654321" });

    const panVerify = await request(app)
      .post("/v1/kyc/pan/verify")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ pan_number: "ABCDE1234F" });

    expect(panVerify.status).toBe(200);
    expect(panVerify.body.verified).toBe(true);
    expect(panVerify.body.reference_id).toEqual(expect.any(String));

    await request(app)
      .post("/v1/kyc/selfie")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .attach("selfie", Buffer.from("fake-image-bytes"), {
        filename: "selfie.jpg",
        contentType: "image/jpeg",
      });

    await request(app)
      .post("/v1/kyc/submit")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({});

    const approve = await request(app)
      .post(`/v1/admin/kyc/${auth.userId}/approve`)
      .set(adminHeaders)
      .send({});

    expect(approve.body.kyc_status).toBe("enhanced_verified");
  });

  it("records admin rejection with reason and cooldown metadata", async () => {
    const auth = await signIn(app, "+919876543212");
    const admin = await seedAdmin();
    const adminHeaders = adminAuthHeaders(admin.id, admin.role);

    const sendOtp = await request(app)
      .post("/v1/kyc/aadhaar/send-otp")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ aadhaar_number: "111122223333" });

    await request(app)
      .post("/v1/kyc/aadhaar/verify")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({ session_id: sendOtp.body.session_id, otp: "654321" });

    await request(app)
      .post("/v1/kyc/selfie")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .attach("selfie", Buffer.from("fake-image-bytes"), {
        filename: "selfie.jpg",
        contentType: "image/jpeg",
      });

    await request(app)
      .post("/v1/kyc/submit")
      .set("Authorization", `Bearer ${auth.accessToken}`)
      .send({});

    const reject = await request(app)
      .post(`/v1/admin/kyc/${auth.userId}/reject`)
      .set(adminHeaders)
      .send({ reason: "Selfie image quality is insufficient" });

    expect(reject.status).toBe(200);
    expect(reject.body.kyc_status).toBe("rejected");

    const status = await request(app)
      .get("/v1/kyc/status")
      .set("Authorization", `Bearer ${auth.accessToken}`);

    expect(status.body.rejection_reason).toBe(
      "Selfie image quality is insufficient",
    );
    expect(status.body.resubmission_allowed_at).toEqual(expect.any(String));
  });
});
