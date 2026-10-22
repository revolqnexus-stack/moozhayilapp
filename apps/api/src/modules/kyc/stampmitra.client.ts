import { logger } from "../../utils/logger";

const STAMPMITRA_BASE_URL = "https://api-b2b.stampmitra.in";
const REQUEST_TIMEOUT_MS = 15_000;

export interface StampMitraErrorBody {
  error: {
    code: string;
    message: string;
    requestId?: string;
  };
}

export class StampMitraError extends Error {
  readonly status: number;
  readonly code: string;
  readonly requestId?: string;

  constructor(status: number, code: string, message: string, requestId?: string) {
    super(message);
    this.name = "StampMitraError";
    this.status = status;
    this.code = code;
    this.requestId = requestId;
  }
}

export interface StampMitraIfscDetails {
  bank?: string;
  ifsc?: string;
  micr?: string;
  address?: string;
  city?: string;
  state?: string;
  branch?: string;
}

export interface StampMitraBankAccountVerifyResponse {
  referenceId: string;
  valid: boolean;
  nameAtBank: string;
  bankName: string;
  utr: string;
  city: string;
  branch: string;
  micr: string;
  nameMatchScore: string;
  nameMatchResult: string;
  accountStatus: string;
  accountStatusCode: string;
  ifscDetails?: StampMitraIfscDetails;
}

export interface StampMitraPanVerifyResponse {
  referenceId: string;
  valid: boolean;
  registeredName: string;
  panStatus: string;
  nameMatchResult: string;
  message: string;
}

function jitterMs(baseMs: number): number {
  return baseMs + Math.floor(Math.random() * 250);
}

function parseRetryAfterMs(header: string | null): number | undefined {
  if (!header) {
    return undefined;
  }

  const seconds = Number(header);
  if (Number.isFinite(seconds) && seconds >= 0) {
    return Math.min(seconds * 1000, 60_000);
  }

  const dateMs = Date.parse(header);
  if (!Number.isNaN(dateMs)) {
    return Math.max(0, Math.min(dateMs - Date.now(), 60_000));
  }

  return undefined;
}

async function parseErrorResponse(
  response: Response,
): Promise<StampMitraError> {
  let code = "UNKNOWN";
  let message = `StampMitra request failed (${response.status})`;
  let requestId: string | undefined;

  try {
    const body = (await response.json()) as StampMitraErrorBody;
    if (body.error) {
      code = body.error.code ?? code;
      message = body.error.message ?? message;
      requestId = body.error.requestId;
    }
  } catch {
    // ignore non-JSON bodies
  }

  return new StampMitraError(response.status, code, message, requestId);
}

function shouldRetryStatus(status: number): boolean {
  return status === 429 || status >= 500;
}

function maxAttemptsForRetry(status: number, method: string): number {
  if (status === 429) {
    return 4;
  }

  if (status >= 500) {
    return method === "GET" ? 3 : 2;
  }

  return 1;
}

async function stampMitraFetch(
  path: string,
  init: RequestInit,
  method: string,
): Promise<Response> {
  const apiKey = requireStampMitraApiKey();
  const url = `${STAMPMITRA_BASE_URL}${path}`;

  let attempt = 0;

  while (true) {
    attempt += 1;

    try {
      const response = await fetch(url, {
        ...init,
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
          ...(init.headers ?? {}),
        },
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });

      if (response.ok) {
        return response;
      }

      const stampError = await parseErrorResponse(response);
      const maxAttempts = maxAttemptsForRetry(response.status, method);

      if (!shouldRetryStatus(response.status) || attempt >= maxAttempts) {
        throw stampError;
      }

      const retryAfterMs =
        response.status === 429
          ? parseRetryAfterMs(response.headers.get("Retry-After"))
          : undefined;
      const backoffMs = jitterMs(200 * 2 ** (attempt - 1));
      await new Promise((resolve) => {
        setTimeout(resolve, retryAfterMs ?? backoffMs);
      });
    } catch (error) {
      if (error instanceof StampMitraError) {
        const maxAttempts = maxAttemptsForRetry(error.status, method);
        if (!shouldRetryStatus(error.status) || attempt >= maxAttempts) {
          throw error;
        }

        const backoffMs = jitterMs(200 * 2 ** (attempt - 1));
        await new Promise((resolve) => {
          setTimeout(resolve, backoffMs);
        });
        continue;
      }

      const maxAttempts = method === "GET" ? 3 : 2;
      if (attempt >= maxAttempts) {
        throw error;
      }

      const backoffMs = jitterMs(200 * 2 ** (attempt - 1));
      await new Promise((resolve) => {
        setTimeout(resolve, backoffMs);
      });
    }
  }
}

export function requireStampMitraApiKey(): string {
  const key = process.env.STAMPMITRA_API_KEY?.trim();
  if (!key) {
    throw new Error(
      "STAMPMITRA_API_KEY is not set. Add your sandbox key (sk_test_...) to .env.local or .env.",
    );
  }

  return key.trim();
}

export async function verifyPanWithStampMitra(input: {
  pan: string;
  name?: string;
}): Promise<StampMitraPanVerifyResponse> {
  const body: Record<string, string> = { pan: input.pan };
  if (input.name) {
    body.name = input.name;
  }

  const response = await stampMitraFetch(
    "/v1/verify/pan",
    {
      method: "POST",
      body: JSON.stringify(body),
    },
    "POST",
  );

  const payload = (await response.json()) as {
    referenceId: string;
    valid: boolean;
    registeredName?: string;
    panStatus?: string;
    nameMatchResult?: string;
    message?: string;
  };

  return {
    referenceId: payload.referenceId,
    valid: payload.valid,
    registeredName: payload.registeredName ?? "",
    panStatus: payload.panStatus ?? "",
    nameMatchResult: payload.nameMatchResult ?? "",
    message: payload.message ?? "",
  };
}

export async function verifyBankAccountWithStampMitra(input: {
  accountNumber: string;
  ifsc: string;
  name?: string;
}): Promise<StampMitraBankAccountVerifyResponse> {
  const body: Record<string, string> = {
    accountNumber: input.accountNumber,
    ifsc: input.ifsc,
  };
  if (input.name) {
    body.name = input.name;
  }

  const response = await stampMitraFetch(
    "/v1/verify/bank-account",
    {
      method: "POST",
      body: JSON.stringify(body),
    },
    "POST",
  );

  const payload = (await response.json()) as StampMitraBankAccountVerifyResponse;

  return {
    referenceId: payload.referenceId,
    valid: payload.valid,
    nameAtBank: payload.nameAtBank ?? "",
    bankName: payload.bankName ?? "",
    utr: payload.utr ?? "",
    city: payload.city ?? "",
    branch: payload.branch ?? "",
    micr: payload.micr ?? "",
    nameMatchScore: payload.nameMatchScore ?? "",
    nameMatchResult: payload.nameMatchResult ?? "",
    accountStatus: payload.accountStatus ?? "",
    accountStatusCode: payload.accountStatusCode ?? "",
    ifscDetails: payload.ifscDetails,
  };
}

export function logStampMitraFailure(context: {
  operation: string;
  requestId?: string;
  referenceId?: string;
  status?: number;
  code?: string;
}): void {
  const meta = {
    operation: context.operation,
    request_id: context.requestId,
    reference_id: context.referenceId,
    status: context.status,
    code: context.code,
  };

  try {
    logger.error("[stampmitra] request failed", meta);
  } catch {
    console.error(
      JSON.stringify({
        timestamp: new Date().toISOString(),
        level: "error",
        message: "[stampmitra] request failed",
        ...meta,
      }),
    );
  }
}
