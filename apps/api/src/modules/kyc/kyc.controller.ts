import type { Request, Response } from "express";
import type { RequestHandler } from "express";
import multer from "multer";
import { z } from "zod";
import { AppError } from "../../middleware/error.middleware";
import {
  sendAadhaarOtpSchema,
  verifyAadhaarOtpSchema,
  verifyBankAccountSchema,
  verifyPanSchema,
} from "./kyc.schema";
import { kycService } from "./kyc.service";

function requireUserId(req: Request): string {
  if (!req.user) {
    throw new AppError(401, "UNAUTHORIZED", "Missing access token");
  }

  return req.user.userId;
}

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024, files: 1 },
});

export const uploadSelfieMiddleware: RequestHandler = (req, res, next) => {
  upload.single("selfie")(req, res, (error) => {
    if (error instanceof multer.MulterError) {
      next(new AppError(422, "UNPROCESSABLE", error.message));
      return;
    }

    if (error) {
      next(error);
      return;
    }

    next();
  });
};

export class KycController {
  async status(req: Request, res: Response): Promise<void> {
    res.status(200).json(await kycService.getStatus(requireUserId(req)));
  }

  async sendAadhaarOtp(req: Request, res: Response): Promise<void> {
    const input = sendAadhaarOtpSchema.parse(req.body);
    res
      .status(200)
      .json(await kycService.sendAadhaarOtp(requireUserId(req), input));
  }

  async verifyAadhaarOtp(req: Request, res: Response): Promise<void> {
    const input = verifyAadhaarOtpSchema.parse(req.body);
    res
      .status(200)
      .json(await kycService.verifyAadhaarOtp(requireUserId(req), input));
  }

  async verifyPan(req: Request, res: Response): Promise<void> {
    const input = verifyPanSchema.parse(req.body);
    res.status(200).json(await kycService.verifyPan(requireUserId(req), input));
  }

  async verifyBankAccount(req: Request, res: Response): Promise<void> {
    const input = verifyBankAccountSchema.parse(req.body);
    res
      .status(200)
      .json(await kycService.verifyBankAccount(requireUserId(req), input));
  }

  async uploadSelfie(req: Request, res: Response): Promise<void> {
    const file = req.file;
    if (!file) {
      throw new AppError(422, "UNPROCESSABLE", "Selfie file is required");
    }

    res.status(200).json(
      await kycService.uploadSelfie(requireUserId(req), {
        buffer: file.buffer,
        mimetype: file.mimetype,
        size: file.size,
      }),
    );
  }

  async submit(req: Request, res: Response): Promise<void> {
    z.object({}).parse(req.body ?? {});
    res.status(200).json(await kycService.submit(requireUserId(req)));
  }
}

export const kycController = new KycController();
