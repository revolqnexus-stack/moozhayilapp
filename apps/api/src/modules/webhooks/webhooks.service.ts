import { randomUUID } from "crypto";
import type { Prisma } from "@prisma/client";
import { prisma } from "../../db/prisma";
import { paymentProviderClient } from "../payments/payment_provider.client";
import { processPaymentWebhookEvent } from "../../jobs/processors/payment_webhook.processor";
import { processKycWebhookEvent } from "../../jobs/processors/kyc_webhook.processor";
import { processGoldRateWebhookEvent } from "../../jobs/processors/gold_rate_webhook.processor";
import {
  verifyGoldRateWebhookSignature,
  verifyKycWebhookSignature,
} from "./webhook_signature";

export class WebhooksService {
  async ingestPaymentWebhook(input: {
    rawBody: string;
    signature: string | undefined;
    timestamp: string | undefined;
    payload: Record<string, unknown>;
  }) {
    const signatureValid = paymentProviderClient.verifyWebhookSignature(
      input.rawBody,
      input.signature,
      input.timestamp,
    );

    const eventId =
      typeof input.payload.id === "string"
        ? input.payload.id
        : `evt_${randomUUID()}`;
    const eventType =
      typeof input.payload.event === "string"
        ? input.payload.event
        : "payment.unknown";

    const existing = await prisma.webhookEvent.findUnique({
      where: {
        provider_providerEventId: {
          provider: "razorpay",
          providerEventId: eventId,
        },
      },
    });

    if (existing) {
      await prisma.webhookEvent.update({
        where: { id: existing.id },
        data: { status: "ignored_duplicate" },
      });

      return { received: true, duplicate: true };
    }

    const event = await prisma.webhookEvent.create({
      data: {
        provider: "razorpay",
        providerEventId: eventId,
        eventType,
        status: signatureValid ? "received" : "failed",
        payload: input.payload as Prisma.InputJsonValue,
        signatureValid,
        receivedAt: new Date(),
        errorMessage: signatureValid ? null : "Invalid webhook signature",
      },
    });

    if (signatureValid) {
      await processPaymentWebhookEvent(event.id);
    }

    return { received: true, duplicate: false };
  }

  async ingestKycWebhook(input: {
    rawBody: string;
    signature: string | undefined;
    payload: Record<string, unknown>;
  }) {
    return this.ingestProviderWebhook({
      provider: "kyc_provider",
      rawBody: input.rawBody,
      signature: input.signature,
      payload: input.payload,
      verify: verifyKycWebhookSignature,
      process: processKycWebhookEvent,
    });
  }

  async ingestGoldRateWebhook(input: {
    rawBody: string;
    signature: string | undefined;
    payload: Record<string, unknown>;
  }) {
    return this.ingestProviderWebhook({
      provider: "gold_rate_provider",
      rawBody: input.rawBody,
      signature: input.signature,
      payload: input.payload,
      verify: verifyGoldRateWebhookSignature,
      process: processGoldRateWebhookEvent,
    });
  }

  private async ingestProviderWebhook(input: {
    provider: string;
    rawBody: string;
    signature: string | undefined;
    payload: Record<string, unknown>;
    verify: (rawBody: string, signature: string | undefined) => boolean;
    process: (eventId: string) => Promise<void>;
  }) {
    const signatureValid = input.verify(input.rawBody, input.signature);
    const eventId =
      typeof input.payload.id === "string"
        ? input.payload.id
        : `evt_${randomUUID()}`;
    const eventType =
      typeof input.payload.event === "string"
        ? input.payload.event
        : "unknown";

    const existing = await prisma.webhookEvent.findUnique({
      where: {
        provider_providerEventId: {
          provider: input.provider,
          providerEventId: eventId,
        },
      },
    });

    if (existing) {
      await prisma.webhookEvent.update({
        where: { id: existing.id },
        data: { status: "ignored_duplicate" },
      });
      return { received: true, duplicate: true };
    }

    const event = await prisma.webhookEvent.create({
      data: {
        provider: input.provider,
        providerEventId: eventId,
        eventType,
        status: signatureValid ? "received" : "failed",
        payload: input.payload as Prisma.InputJsonValue,
        signatureValid,
        receivedAt: new Date(),
        errorMessage: signatureValid ? null : "Invalid webhook signature",
      },
    });

    if (signatureValid) {
      await input.process(event.id);
    }

    return { received: true, duplicate: false };
  }
}

export const webhooksService = new WebhooksService();
