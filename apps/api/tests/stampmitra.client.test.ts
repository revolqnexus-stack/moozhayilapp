import dotenv from "dotenv";
import { AppError } from "../src/middleware/error.middleware";

dotenv.config();

function stripEmptyEnv(keys: string[]) {
  for (const key of keys) {
    if (process.env[key] === "") {
      delete process.env[key];
    }
  }
}

import { mapStampMitraErrorToAppError } from "../src/modules/kyc/stampmitra.errors";
import {
  StampMitraError,
  verifyBankAccountWithStampMitra,
  verifyPanWithStampMitra,
} from "../src/modules/kyc/stampmitra.client";

const originalFetch = global.fetch;

describe("StampMitra client", () => {
  beforeAll(() => {
    stripEmptyEnv([
      "KYC_PROVIDER_BASE_URL",
      "KYC_PROVIDER_API_KEY",
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
  });

  beforeEach(() => {
    process.env.STAMPMITRA_API_KEY = "sk_test_stampmitra_unit_test_key";
  });

  afterEach(() => {
    global.fetch = originalFetch;
    jest.restoreAllMocks();
  });

  it("validates PAN request shape and maps a successful response", async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({
        referenceId: "SMV-20260927-8F42K7",
        valid: true,
        registeredName: "RAHUL KUMAR",
        panStatus: "VALID",
        nameMatchResult: "MATCH",
        message: "PAN is Valid",
      }),
    }) as unknown as typeof fetch;

    const result = await verifyPanWithStampMitra({
      pan: "ABCDE1234F",
      name: "Rahul Kumar",
    });

    expect(result.referenceId).toBe("SMV-20260927-8F42K7");
    expect(result.valid).toBe(true);
    expect(result.registeredName).toBe("RAHUL KUMAR");

    const [url, init] = (global.fetch as jest.Mock).mock.calls[0] as [
      string,
      RequestInit,
    ];
    expect(url).toBe("https://api-b2b.stampmitra.in/v1/verify/pan");
    expect(init.method).toBe("POST");
    expect(JSON.parse(String(init.body))).toEqual({
      pan: "ABCDE1234F",
      name: "Rahul Kumar",
    });
    expect((init.headers as Record<string, string>).Authorization).toMatch(
      /^Bearer sk_test_/,
    );
  });

  it("maps 401 to provider unavailable for customers", () => {
    const mapped = mapStampMitraErrorToAppError(
      new StampMitraError(401, "UNAUTHORIZED", "Invalid API key", "req-401"),
      {
        operation: "verify_pan",
        requiredScope: "verification.pan.read",
      },
    );

    expect(mapped).toBeInstanceOf(AppError);
    expect(mapped.statusCode).toBe(503);
    expect(mapped.code).toBe("PROVIDER_UNAVAILABLE");
    expect(mapped.details?.stampmitra_request_id).toBe("req-401");
  });

  it("maps 403 with required scope detail", () => {
    const mapped = mapStampMitraErrorToAppError(
      new StampMitraError(
        403,
        "FORBIDDEN",
        "Missing scope",
        "req-403",
      ),
      {
        operation: "verify_bank_account",
        requiredScope: "verification.bank-account.read",
      },
    );

    expect(mapped.statusCode).toBe(403);
    expect(mapped.details?.required_scope).toBe(
      "verification.bank-account.read",
    );
  });

  it("posts bank-account verification with StampMitra field names", async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({
        referenceId: "SMV-20260927-3B71A0",
        valid: true,
        nameAtBank: "RAVI KUMAR",
        bankName: "ICICI Bank",
        nameMatchResult: "GOOD_MATCH",
        accountStatus: "ACCOUNT_IS_VALID",
        accountStatusCode: "1",
      }),
    }) as unknown as typeof fetch;

    const result = await verifyBankAccountWithStampMitra({
      accountNumber: "000123456789",
      ifsc: "ICIC0001234",
      name: "Ravi Kumar",
    });

    expect(result.referenceId).toBe("SMV-20260927-3B71A0");
    const [url, init] = (global.fetch as jest.Mock).mock.calls[0] as [
      string,
      RequestInit,
    ];
    expect(url).toBe("https://api-b2b.stampmitra.in/v1/verify/bank-account");
    expect(JSON.parse(String(init.body))).toEqual({
      accountNumber: "000123456789",
      ifsc: "ICIC0001234",
      name: "Ravi Kumar",
    });
  });

  it("retries 429 responses before failing", async () => {
    const fetchMock = jest
      .fn()
      .mockResolvedValueOnce({
        ok: false,
        status: 429,
        headers: { get: () => null },
        json: async () => ({
          error: {
            code: "TOO_MANY_REQUESTS",
            message: "Slow down",
            requestId: "req-429",
          },
        }),
      })
      .mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => ({
          referenceId: "SMV-RETRY",
          valid: true,
          registeredName: "RAHUL KUMAR",
          panStatus: "VALID",
          nameMatchResult: "MATCH",
          message: "PAN is Valid",
        }),
      });

    global.fetch = fetchMock as unknown as typeof fetch;

    const result = await verifyPanWithStampMitra({ pan: "ABCDE1234F" });
    expect(result.referenceId).toBe("SMV-RETRY");
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });
});
