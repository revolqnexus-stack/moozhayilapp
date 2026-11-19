import { StampMitraClient, StampMitraError } from "../src/modules/stampmitra/stampmitra.client";
import { isPanNameMismatch, verifyPanSchema } from "../src/modules/kyc/kyc.schema";
import { mapPanProviderError } from "../src/modules/kyc/kyc.service";

const samplePan = {
  referenceId: "SMV-20260927-8F42K7",
  pan: "ABCDE1234F",
  valid: true,
  registeredName: "RAHUL KUMAR",
  panStatus: "VALID",
  nameMatchResult: "MATCH",
  message: "PAN is Valid",
};

function jsonResponse(status: number, body: unknown, headers?: Record<string, string>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...headers },
  });
}

const testEnv = {
  NODE_ENV: "test",
  DATABASE_URL: "postgresql://postgres:postgres@localhost:5432/moozhayil",
  REDIS_URL: "redis://localhost:6379",
  STAMPMITRA_API_KEY: "sk_test_xxx",
};

function client(fetchImpl: typeof fetch) {
  return new StampMitraClient({
    fetch: fetchImpl,
    sleep: async () => undefined,
    random: () => 0,
    env: testEnv,
  });
}

function lastRequest(fetchImpl: jest.Mock): RequestInit {
  const call = fetchImpl.mock.calls[0];
  expect(call).toBeDefined();
  return (call?.[1] ?? {}) as RequestInit;
}

beforeAll(() => {
  process.env.NODE_ENV ??= "test";
  process.env.DATABASE_URL ??= testEnv.DATABASE_URL;
  process.env.REDIS_URL ??= testEnv.REDIS_URL;
});

describe("StampMitra PAN client", () => {
  it("reads a sandbox PAN verification response", async () => {
    const fetchImpl = jest.fn(async () => jsonResponse(200, samplePan));
    const result = await client(fetchImpl).verifyPan({
      pan: "ABCDE1234F",
      name: "Rahul Kumar",
    });

    expect(result).toEqual({
      referenceId: "SMV-20260927-8F42K7",
      valid: true,
      registeredName: "RAHUL KUMAR",
      panStatus: "VALID",
      nameMatchResult: "MATCH",
      message: "PAN is Valid",
    });

    const init = lastRequest(fetchImpl);
    expect(init.headers).toMatchObject({
      Authorization: "Bearer sk_test_xxx",
      "Content-Type": "application/json",
    });
    expect(JSON.parse(String(init.body))).toEqual({
      pan: "ABCDE1234F",
      name: "Rahul Kumar",
    });
    expect(String(init.body)).not.toContain("sk_test_xxx");
  });

  it("omits name when the caller did not send one", async () => {
    const fetchImpl = jest.fn(async () => jsonResponse(200, samplePan));
    await client(fetchImpl).verifyPan({ pan: "ABCDE1234F" });
    const init = lastRequest(fetchImpl);
    expect(JSON.parse(String(init.body))).toEqual({ pan: "ABCDE1234F" });
  });

  it("does not retry a 400 validation error", async () => {
    const fetchImpl = jest.fn(async () =>
      jsonResponse(400, {
        error: {
          code: "BAD_REQUEST",
          message: "pan is invalid",
          requestId: "req_400",
        },
      }),
    );

    const error = await client(fetchImpl)
      .verifyPan({ pan: "ABCDE1234F" })
      .catch((caught: unknown) => caught);

    expect(fetchImpl).toHaveBeenCalledTimes(1);
    expect(error).toBeInstanceOf(StampMitraError);
    expect(error).toMatchObject({
      status: 400,
      code: "BAD_REQUEST",
      requestId: "req_400",
    });
  });

  it("treats a missing key as 401 and does not call StampMitra", async () => {
    const fetchImpl = jest.fn();
    const missingKey = new StampMitraClient({
      fetch: fetchImpl,
      env: { ...testEnv, STAMPMITRA_API_KEY: undefined },
    });

    await expect(missingKey.verifyPan({ pan: "ABCDE1234F" })).rejects.toMatchObject({
      status: 401,
      code: "UNAUTHORIZED",
    });
    expect(fetchImpl).not.toHaveBeenCalled();
  });

  it("retries 429 three times and honours Retry-After", async () => {
    const sleeps: number[] = [];
    const fetchImpl = jest.fn(async () =>
      jsonResponse(
        429,
        {
          error: {
            code: "TOO_MANY_REQUESTS",
            message: "slow down",
            requestId: "req_429",
          },
        },
        { "retry-after": "2" },
      ),
    );
    const limited = new StampMitraClient({
      fetch: fetchImpl,
      sleep: async (ms) => {
        sleeps.push(ms);
      },
      random: () => 0,
      env: testEnv,
    });

    await expect(limited.verifyPan({ pan: "ABCDE1234F" })).rejects.toMatchObject({
      status: 429,
      requestId: "req_429",
    });
    expect(fetchImpl).toHaveBeenCalledTimes(4);
    expect(sleeps).toEqual([2000, 2000, 2000]);
  });

  it("retries a POST 502 once", async () => {
    const fetchImpl = jest.fn(async () =>
      jsonResponse(502, {
        error: {
          code: "BAD_GATEWAY",
          message: "upstream unavailable",
          requestId: "req_502",
        },
      }),
    );

    await expect(client(fetchImpl).verifyPan({ pan: "ABCDE1234F" })).rejects.toMatchObject({
      status: 502,
      requestId: "req_502",
    });
    expect(fetchImpl).toHaveBeenCalledTimes(2);
  });

  it("retries a network timeout once", async () => {
    const fetchImpl = jest.fn(async () => {
      throw new Error("network down");
    });

    await expect(client(fetchImpl).verifyPan({ pan: "ABCDE1234F" })).rejects.toMatchObject({
      status: 504,
      code: "UPSTREAM_TIMEOUT",
    });
    expect(fetchImpl).toHaveBeenCalledTimes(2);
  });
});

describe("PAN validation", () => {
  it("rejects a malformed PAN with a field message", () => {
    const parsed = verifyPanSchema.safeParse({ pan_number: "abc" });
    expect(parsed.success).toBe(false);
    if (!parsed.success) {
      expect(parsed.error.flatten().fieldErrors.pan_number?.[0]).toBe(
        "Enter a valid PAN (ABCDE1234F)",
      );
    }
  });

  it("uppercases the PAN and drops a blank name", () => {
    const parsed = verifyPanSchema.parse({
      pan_number: " abcde1234f ",
      name: "   ",
    });
    expect(parsed).toEqual({ pan_number: "ABCDE1234F", name: undefined });
  });

  it("keeps a trimmed name", () => {
    const parsed = verifyPanSchema.parse({
      pan_number: "ABCDE1234F",
      name: " Rahul Kumar ",
    });
    expect(parsed.name).toBe("Rahul Kumar");
  });

  it("treats a non-matching name result as a mismatch only when a name was sent", () => {
    expect(isPanNameMismatch("Rahul", "NO_MATCH")).toBe(true);
    expect(isPanNameMismatch("Rahul", "MATCH")).toBe(false);
    expect(isPanNameMismatch(undefined, "NO_MATCH")).toBe(false);
  });
});

describe("PAN provider errors shown to customers", () => {
  it("hides an invalid key behind a generic unavailable message", () => {
    const error = mapPanProviderError(
      new StampMitraError(401, "UNAUTHORIZED", "STAMPMITRA_API_KEY is missing", {
        requestId: "req_401",
      }),
    );
    expect(error.statusCode).toBe(503);
    expect(error.message).toBe("Verification is temporarily unavailable.");
    expect(error.message).not.toContain("STAMPMITRA_API_KEY");
  });

  it("asks the customer to try again shortly after rate limiting", () => {
    const error = mapPanProviderError(
      new StampMitraError(429, "TOO_MANY_REQUESTS", "slow down"),
    );
    expect(error.statusCode).toBe(429);
    expect(error.message).toBe("Please try again shortly.");
  });

  it("names the scope required for a forbidden key", () => {
    const error = mapPanProviderError(
      new StampMitraError(403, "FORBIDDEN", "missing scope"),
    );
    expect(error.message).toContain("verification.pan.read");
  });
});
