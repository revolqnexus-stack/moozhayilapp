import { loadEnv } from "../../config/env";
import { logger } from "../../utils/logger";

const STAMPMITRA_BASE_URL = "https://api-b2b.stampmitra.in";
const REQUEST_TIMEOUT_MS = 15_000;
const PAN_SCOPE = "verification.pan.read";

export class StampMitraError extends Error {
  readonly status: number;
  readonly code: string;
  readonly requestId?: string;
  readonly referenceId?: string;
  readonly retryAfterMs?: number;

  constructor(
    status: number,
    code: string,
    message: string,
    meta: {
      requestId?: string;
      referenceId?: string;
      retryAfterMs?: number;
    } = {},
  ) {
    super(message);
    this.name = "StampMitraError";
    this.status = status;
    this.code = code;
    this.requestId = meta.requestId;
    this.referenceId = meta.referenceId;
    this.retryAfterMs = meta.retryAfterMs;
  }
}

export interface PanVerification {
  referenceId: string;
  valid: boolean;
  registeredName: string | null;
  panStatus: string;
  nameMatchResult: string | null;
  message: string;
}

export interface BankVerification {
  referenceId: string;
  verified: boolean;
  accountStatus?: string;
  nameMatchResult?: string;
  nameAtBankMasked?: string;
  bankName?: string;
  branch?: string;
  accountMasked?: string;
  message: string;
}

export interface StampMitraClientOptions {
  fetch?: typeof fetch;
  sleep?: (ms: number) => Promise<void>;
  random?: () => number;
  env?: NodeJS.ProcessEnv;
}

function defaultSleep(ms: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

function parseRetryAfter(header: string | null): number | undefined {
  if (!header) {
    return undefined;
  }

  const seconds = Number(header);
  if (Number.isFinite(seconds) && seconds >= 0) {
    return Math.round(seconds * 1000);
  }

  const dateMs = Date.parse(header);
  if (Number.isNaN(dateMs)) {
    return undefined;
  }

  return Math.max(0, dateMs - Date.now());
}

function backoffMs(retryIndex: number, random: () => number): number {
  const base = Math.min(200 * 2 ** retryIndex, 2_000);
  const jitter = base * random();
  return Math.round(base + jitter);
}

function isRetryableServerStatus(status: number): boolean {
  return status >= 500 || status === 502;
}

function logFailure(error: StampMitraError, alert: boolean): void {
  const meta = {
    status: error.status,
    code: error.code,
    requestId: error.requestId ?? null,
    referenceId: error.referenceId ?? null,
  };

  if (alert) {
    logger.error("StampMitra wallet balance is insufficient", meta);
    return;
  }

  logger.error("StampMitra request failed", meta);
}

export class StampMitraClient {
  private readonly fetchImpl: typeof fetch;
  private readonly sleep: (ms: number) => Promise<void>;
  private readonly random: () => number;
  private readonly env: NodeJS.ProcessEnv;

  constructor(options: StampMitraClientOptions = {}) {
    this._fetchImpl = options.fetch;
    this.sleep = options.sleep ?? defaultSleep;
    this.random = options.random ?? Math.random;
    this.env = options.env ?? process.env;
  }

  async verifyPan(input: { pan: string; name?: string }): Promise<PanVerification> {
    const body: { pan: string; name?: string } = { pan: input.pan };
    if (input.name) {
      body.name = input.name;
    }

    return this.post<PanVerification>("/v1/verify/pan", body, readPanVerification);
  }

  async verifyBankAccount(input: {
    accountNumber: string;
    ifsc: string;
    name?: string;
  }): Promise<BankVerification> {
    const body: Record<string, unknown> = {
      account_number: input.accountNumber,
      ifsc: input.ifsc,
    };
    if (input.name) {
      body.name = input.name;
    }

    return this.post<BankVerification>("/v1/verify/bank-account", body, readBankVerification);
  }

  private async post<T>(
    path: string,
    body: Record<string, unknown>,
    read: (payload: unknown) => T,
  ): Promise<T> {
    const apiKey = loadEnv(this.env).STAMPMITRA_API_KEY;
    if (!apiKey) {
      const error = new StampMitraError(
        401,
        "UNAUTHORIZED",
        "STAMPMITRA_API_KEY is missing",
      );
      logFailure(error, false);
      throw error;
    }

    let rateLimitRetries = 0;
    let serverRetries = 0;

    for (;;) {
      let response: Response;
      try {
        response = await (this._fetchImpl ?? fetch)(`${STAMPMITRA_BASE_URL}${path}`, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
        });
      } catch {
        const error = new StampMitraError(
          504,
          "UPSTREAM_TIMEOUT",
          "StampMitra did not respond in time",
        );
        if (!this.canRetryServer("POST", serverRetries)) {
          logFailure(error, false);
          throw error;
        }
        logger.warn("StampMitra request failed and will be retried", {
          status: error.status,
          code: error.code,
          requestId: error.requestId ?? null,
          referenceId: error.referenceId ?? null,
        });
        serverRetries += 1;
        await this.sleep(backoffMs(serverRetries - 1, this.random));
        continue;
      }

      if (response.ok) {
        let payload: unknown;
        try {
          payload = await response.json();
        } catch {
          const error = new StampMitraError(
            502,
            "BAD_RESPONSE",
            "StampMitra returned an unreadable response",
          );
          logFailure(error, false);
          throw error;
        }

        try {
          return read(payload);
        } catch (cause) {
          if (cause instanceof StampMitraError) {
            logFailure(cause, false);
          }
          throw cause;
        }
      }

      const error = await readError(response);
      const retryDelay = this.retryDelay(
        "POST",
        error,
        rateLimitRetries,
        serverRetries,
      );
      if (retryDelay === null) {
        logFailure(error, error.status === 402);
        throw error;
      }

      logger.warn("StampMitra request failed and will be retried", {
        status: error.status,
        code: error.code,
        requestId: error.requestId ?? null,
        referenceId: error.referenceId ?? null,
      });

      if (error.status === 429) {
        rateLimitRetries += 1;
      } else {
        serverRetries += 1;
      }

      await this.sleep(retryDelay);
    }
  }

  private canRetryServer(method: "GET" | "POST", serverRetries: number): boolean {
    return serverRetries < (method === "GET" ? 2 : 1);
  }

  private retryDelay(
    method: "GET" | "POST",
    error: StampMitraError,
    rateLimitRetries: number,
    serverRetries: number,
  ): number | null {
    if (error.status === 429) {
      if (rateLimitRetries >= 3) {
        return null;
      }
      return error.retryAfterMs ?? backoffMs(rateLimitRetries, this.random);
    }

    if (!isRetryableServerStatus(error.status)) {
      return null;
    }

    if (!this.canRetryServer(method, serverRetries)) {
      return null;
    }

    return backoffMs(serverRetries, this.random);
  }
}

async function readError(response: Response): Promise<StampMitraError> {
  let code = "UPSTREAM_ERROR";
  let message = "StampMitra request failed";
  let requestId: string | undefined;
  let referenceId: string | undefined;

  try {
    const payload = (await response.json()) as {
      referenceId?: unknown;
      error?: { code?: unknown; message?: unknown; requestId?: unknown };
    };
    if (typeof payload.referenceId === "string") {
      referenceId = payload.referenceId;
    }
    const error = payload.error;
    if (error && typeof error === "object") {
      if (typeof error.code === "string") {
        code = error.code;
      }
      if (typeof error.message === "string") {
        message = error.message;
      }
      if (typeof error.requestId === "string") {
        requestId = error.requestId;
      }
    }
  } catch {
    code = "UPSTREAM_ERROR";
  }

  return new StampMitraError(response.status, code, message, {
    requestId,
    referenceId,
    retryAfterMs: parseRetryAfter(response.headers.get("retry-after")),
  });
}

function readPanVerification(payload: unknown): PanVerification {
  if (!payload || typeof payload !== "object") {
    throw new StampMitraError(
      502,
      "BAD_RESPONSE",
      "StampMitra returned an unexpected PAN verification response",
    );
  }

  const body = payload as Record<string, unknown>;
  if (
    typeof body.referenceId !== "string" ||
    typeof body.valid !== "boolean" ||
    typeof body.panStatus !== "string" ||
    typeof body.message !== "string"
  ) {
    throw new StampMitraError(
      502,
      "BAD_RESPONSE",
      "StampMitra returned an unexpected PAN verification response",
    );
  }

  return {
    referenceId: body.referenceId,
    valid: body.valid,
    registeredName:
      typeof body.registeredName === "string" ? body.registeredName : null,
    panStatus: body.panStatus,
    nameMatchResult:
      typeof body.nameMatchResult === "string" ? body.nameMatchResult : null,
    message: body.message,
  };
}

function readBankVerification(payload: unknown): BankVerification {
  if (!payload || typeof payload !== "object") {
    throw new StampMitraError(
      502,
      "BAD_RESPONSE",
      "StampMitra returned an unexpected bank verification response",
    );
  }

  const body = payload as Record<string, unknown>;
  if (typeof body.referenceId !== "string" || typeof body.message !== "string") {
    throw new StampMitraError(
      502,
      "BAD_RESPONSE",
      "StampMitra returned an unexpected bank verification response",
    );
  }

  return {
    referenceId: body.referenceId,
    verified: typeof body.verified === "boolean" ? body.verified : false,
    accountStatus:
      typeof body.accountStatus === "string" ? body.accountStatus : undefined,
    nameMatchResult:
      typeof body.nameMatchResult === "string" ? body.nameMatchResult : undefined,
    nameAtBankMasked:
      typeof body.nameAtBankMasked === "string"
        ? body.nameAtBankMasked
        : undefined,
    bankName: typeof body.bankName === "string" ? body.bankName : undefined,
    branch: typeof body.branch === "string" ? body.branch : undefined,
    accountMasked:
      typeof body.accountMasked === "string" ? body.accountMasked : undefined,
    message: body.message,
  };
}

export const PAN_VERIFICATION_SCOPE = PAN_SCOPE;

export const stampMitraClient = new StampMitraClient();
