import { Router } from "express";
import { authenticate } from "../auth/auth.middleware";
import {
  kycController,
  uploadSelfieMiddleware,
} from "./kyc.controller";

export const kycRouter = Router();

// Debug endpoint - no auth required
kycRouter.get("/debug-columns", async (_req, res) => {
  try {
    const { prisma } = await import("../../db/prisma");
    const result = await prisma.$queryRaw`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'kyc_documents' 
      AND column_name LIKE '%pan%'
      ORDER BY column_name
    `;
    res.json({ columns: result });
  } catch (error) {
    res.status(500).json({ error: String(error) });
  }
});

// Debug config endpoint
kycRouter.get("/debug-config", async (_req, res) => {
  const { loadEnv } = await import("../../config/env");
  const env = loadEnv();
  res.json({
    KYC_PROVIDER_MODE: env.KYC_PROVIDER_MODE,
    hasStampmitraKey: !!env.STAMPMITRA_API_KEY,
    stampmitraKeyPrefix: env.STAMPMITRA_API_KEY?.substring(0, 7),
    NODE_ENV: env.NODE_ENV,
  });
});

// Test PAN verification without auth
kycRouter.post("/debug-test-pan", async (_req, res) => {
  try {
    const { kycProviderClient } = await import("./kyc_provider.client");
    const result = await kycProviderClient.verifyPan("ABCDE1234F", "Test User");
    res.json({ success: true, result });
  } catch (error: any) {
    res.status(500).json({ 
      success: false, 
      error: error.message,
      code: error.code,
      statusCode: error.statusCode,
      details: error.details,
    });
  }
});

// List all users in database
kycRouter.get("/debug-users", async (_req, res) => {
  try {
    const { prisma } = await import("../../db/prisma");
    const users = await prisma.user.findMany({
      select: {
        id: true,
        phone: true,
        kycStatus: true,
        createdAt: true,
      },
    });
    res.json({ users, count: users.length });
  } catch (error: any) {
    res.status(500).json({ 
      error: error.message,
    });
  }
});

kycRouter.use(authenticate);

kycRouter.get("/status", (req, res, next) => {
  void kycController.status(req, res).catch(next);
});

kycRouter.post("/aadhaar/send-otp", (req, res, next) => {
  void kycController.sendAadhaarOtp(req, res).catch(next);
});

kycRouter.post("/aadhaar/verify", (req, res, next) => {
  void kycController.verifyAadhaarOtp(req, res).catch(next);
});

kycRouter.post("/pan/verify", (req, res, next) => {
  void kycController.verifyPan(req, res).catch(next);
});

kycRouter.post("/bank-account/verify", (req, res, next) => {
  void kycController.verifyBankAccount(req, res).catch(next);
});

kycRouter.post("/selfie", uploadSelfieMiddleware, (req, res, next) => {
  void kycController.uploadSelfie(req, res).catch(next);
});

kycRouter.post("/submit", (req, res, next) => {
  void kycController.submit(req, res).catch(next);
});
