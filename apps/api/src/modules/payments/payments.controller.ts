import type { Request, Response } from "express";
import { z } from "zod";
import { AppError } from "../../middleware/error.middleware";
import {
  captureCheckoutSchema,
  createPaymentMethodSchema,
  reconcilePaymentSchema,
  verifyUpiSchema,
  verifyRazorpaySignatureSchema,
} from "./payments.schema";
import { paymentsService } from "./payments.service";

function requireUserId(req: Request): string {
  if (!req.user) {
    throw new AppError(401, "UNAUTHORIZED", "Missing access token");
  }

  return req.user.userId;
}

export class PaymentsController {
  async verifyUpi(req: Request, res: Response): Promise<void> {
    const input = verifyUpiSchema.parse(req.body);
    res.status(200).json(paymentsService.verifyUpi(input.upi_id));
  }

  async listMethods(req: Request, res: Response): Promise<void> {
    res.status(200).json(await paymentsService.listMethods(requireUserId(req)));
  }

  async createMethod(req: Request, res: Response): Promise<void> {
    const input = createPaymentMethodSchema.parse(req.body);
    res
      .status(201)
      .json(await paymentsService.createMethod(requireUserId(req), input));
  }

  async deleteMethod(req: Request, res: Response): Promise<void> {
    const methodId = z.string().uuid().parse(req.params.id);
    res
      .status(200)
      .json(await paymentsService.deleteMethod(requireUserId(req), methodId));
  }

  async reconcile(req: Request, res: Response): Promise<void> {
    const input = reconcilePaymentSchema.parse(req.body);
    res
      .status(202)
      .json(await paymentsService.reconcilePayment(input.payment_transaction_id));
  }

  async captureCheckout(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new AppError(401, "UNAUTHORIZED", "Missing access token");
    }
    const input = captureCheckoutSchema.parse(req.body);
    res
      .status(200)
      .json(await paymentsService.captureCheckout(req.user.userId, input));
  }

  async verifyRazorpaySignature(req: Request, res: Response): Promise<void> {
    if (!req.user) {
      throw new AppError(401, "UNAUTHORIZED", "Missing access token");
    }
    const input = verifyRazorpaySignatureSchema.parse(req.body);
    res
      .status(200)
      .json(await paymentsService.verifyRazorpaySignature(req.user.userId, input));
  }
}

export const paymentsController = new PaymentsController();
