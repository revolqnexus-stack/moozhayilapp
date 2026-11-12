import { Router } from "express";
import { authenticate } from "../auth/auth.middleware";
import {
  kycController,
  uploadSelfieMiddleware,
} from "./kyc.controller";

export const kycRouter = Router();

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

// Temporary debug endpoint
kycRouter.get("/debug-columns", async (req, res) => {
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
