import type { Request, Response } from "express";
import { webhooksService } from "./webhooks.service";

export class WebhooksController {
  async payment(req: Request, res: Response): Promise<void> {
    const rawBody = Buffer.isBuffer(req.body)
      ? req.body.toString("utf8")
      : typeof req.body === "string"
        ? req.body
        : JSON.stringify(req.body ?? {});

    const payload = JSON.parse(rawBody) as Record<string, unknown>;

    res.status(200).json(
      await webhooksService.ingestPaymentWebhook({
        rawBody,
        signature: req.header("x-webhook-signature"),
        timestamp: req.header("x-webhook-timestamp"),
        payload,
      }),
    );
  }

  async kyc(req: Request, res: Response): Promise<void> {
    const rawBody = Buffer.isBuffer(req.body)
      ? req.body.toString("utf8")
      : typeof req.body === "string"
        ? req.body
        : JSON.stringify(req.body ?? {});

    const payload = JSON.parse(rawBody) as Record<string, unknown>;

    res.status(200).json(
      await webhooksService.ingestKycWebhook({
        rawBody,
        signature: req.header("x-kyc-signature"),
        payload,
      }),
    );
  }

  async goldRate(req: Request, res: Response): Promise<void> {
    const rawBody = Buffer.isBuffer(req.body)
      ? req.body.toString("utf8")
      : typeof req.body === "string"
        ? req.body
        : JSON.stringify(req.body ?? {});

    const payload = JSON.parse(rawBody) as Record<string, unknown>;

    res.status(200).json(
      await webhooksService.ingestGoldRateWebhook({
        rawBody,
        signature: req.header("x-gold-rate-signature"),
        payload,
      }),
    );
  }
}

export const webhooksController = new WebhooksController();
