import { z } from "zod";

const redisUrlSchema = z
  .string()
  .url()
  .refine(
    (value) => value.startsWith("redis://") || value.startsWith("rediss://"),
    "REDIS_URL must use redis:// or rediss://",
  );

const envSchema = z.object({
  NODE_ENV: z
    .enum(["development", "test", "staging", "production"])
    .default("development"),
  PORT: z.coerce.number().int().positive().default(3080),
  DATABASE_URL: z.string().url().startsWith("postgresql://"),
  REDIS_URL: redisUrlSchema,
  JWT_SECRET: z.string().min(32).optional(),
  JWT_REFRESH_SECRET: z.string().min(32).optional(),
  OTP_HASH_SECRET: z.string().min(32).optional(),
  PII_ENCRYPTION_SECRET: z.string().min(32).optional(),
  ADMIN_JWT_SECRET: z.string().min(32).optional(),
  KYC_PROVIDER_MODE: z.enum(["mock", "live"]).default("mock"),
  KYC_PROVIDER_BASE_URL: z.string().url().optional(),
  KYC_PROVIDER_API_KEY: z.string().min(8).optional(),
  KYC_UPLOAD_DIR: z.string().min(1).default("./uploads/kyc"),
  MEDIA_UPLOAD_DIR: z.string().min(1).default("./uploads/media"),
  STORAGE_BACKEND: z.enum(["local", "s3"]).default("local"),
  S3_ENDPOINT: z.string().url().optional(),
  S3_REGION: z.string().min(1).default("ap-south-1"),
  S3_BUCKET: z.string().min(1).optional(),
  S3_ACCESS_KEY_ID: z.string().min(1).optional(),
  S3_SECRET_ACCESS_KEY: z.string().min(1).optional(),
  S3_PUBLIC_BASE_URL: z.string().url().optional(),
  S3_FORCE_PATH_STYLE: z
    .enum(["true", "false"])
    .default("false")
    .transform((value) => value === "true"),
  PUBLIC_BASE_URL: z.string().url().default("http://localhost:3080"),
  CORS_ALLOWED_ORIGINS: z.string().optional(),
  TRUST_PROXY: z
    .enum(["true", "false"])
    .default("false")
    .transform((value) => value === "true"),
  SMS_PROVIDER_MODE: z.enum(["mock", "live"]).default("mock"),
  MSG91_AUTH_KEY: z.string().min(8).optional(),
  MSG91_OTP_TEMPLATE_ID: z.string().min(1).optional(),
  PAYMENT_PROVIDER: z.enum(["razorpay", "cashfree"]).default("razorpay"),
  PAYMENT_PROVIDER_MODE: z.enum(["mock", "live"]).default("mock"),
  RAZORPAY_KEY_ID: z.string().min(1).optional(),
  RAZORPAY_KEY_SECRET: z.string().min(1).optional(),
  RAZORPAY_WEBHOOK_SECRET: z.string().min(8).optional(),
  CASHFREE_APP_ID: z.string().min(1).optional(),
  CASHFREE_SECRET_KEY: z.string().min(1).optional(),
  CASHFREE_WEBHOOK_SECRET: z.string().min(8).optional(),
  CASHFREE_ENVIRONMENT: z.enum(["sandbox", "production"]).default("sandbox"),
  FIREBASE_MODE: z.enum(["mock", "live"]).default("mock"),
  FIREBASE_PROJECT_ID: z.string().min(1).optional(),
  FIREBASE_CLIENT_EMAIL: z.string().email().optional(),
  FIREBASE_PRIVATE_KEY: z.string().min(1).optional(),
  KYC_WEBHOOK_SECRET: z.string().min(8).optional(),
  GOLD_RATE_WEBHOOK_SECRET: z.string().min(8).optional(),
  SENTRY_DSN: z.string().url().optional(),
  ENABLE_DEMO_SEEDS: z
    .enum(["true", "false"])
    .default("false")
    .transform((value) => value === "true"),
  WORKER_HEALTH_PORT: z.coerce.number().int().positive().default(3001),
  LOG_LEVEL: z
    .enum(["error", "warn", "info", "http", "verbose", "debug", "silly"])
    .default("info"),
});

export type Env = Omit<
  z.infer<typeof envSchema>,
  | "JWT_SECRET"
  | "JWT_REFRESH_SECRET"
  | "OTP_HASH_SECRET"
  | "PII_ENCRYPTION_SECRET"
  | "ADMIN_JWT_SECRET"
> & {
  JWT_SECRET: string;
  JWT_REFRESH_SECRET: string;
  OTP_HASH_SECRET: string;
  PII_ENCRYPTION_SECRET: string;
  ADMIN_JWT_SECRET: string;
};

const developmentSecrets = {
  JWT_SECRET: "dev_jwt_secret_change_before_production_32_chars",
  JWT_REFRESH_SECRET: "dev_refresh_secret_change_before_prod_32_chars",
  OTP_HASH_SECRET: "dev_otp_hash_secret_change_before_prod_32_chars",
  PII_ENCRYPTION_SECRET: "dev_pii_encryption_secret_change_prod_32",
  ADMIN_JWT_SECRET: "dev_admin_jwt_secret_change_before_prod_32",
};

function assertProductionProviderModes(data: z.infer<typeof envSchema>) {
  const mockProviders = [
    data.SMS_PROVIDER_MODE === "mock" ? "SMS_PROVIDER_MODE" : null,
    data.PAYMENT_PROVIDER_MODE === "mock" ? "PAYMENT_PROVIDER_MODE" : null,
    data.KYC_PROVIDER_MODE === "mock" ? "KYC_PROVIDER_MODE" : null,
    data.FIREBASE_MODE === "mock" ? "FIREBASE_MODE" : null,
  ].filter(Boolean);

  if (mockProviders.length > 0) {
    throw new Error(
      `Production requires live provider modes. Mock modes detected: ${mockProviders.join(", ")}`,
    );
  }
}

function assertProductionLiveCredentials(data: z.infer<typeof envSchema>) {
  const missing = [
    data.SMS_PROVIDER_MODE === "live" && !data.MSG91_AUTH_KEY
      ? "MSG91_AUTH_KEY"
      : null,
    data.SMS_PROVIDER_MODE === "live" && !data.MSG91_OTP_TEMPLATE_ID
      ? "MSG91_OTP_TEMPLATE_ID"
      : null,
    data.PAYMENT_PROVIDER === "cashfree" && !data.CASHFREE_APP_ID
      ? "CASHFREE_APP_ID"
      : null,
    data.PAYMENT_PROVIDER === "cashfree" && !data.CASHFREE_SECRET_KEY
      ? "CASHFREE_SECRET_KEY"
      : null,
    data.PAYMENT_PROVIDER === "cashfree" && !data.CASHFREE_WEBHOOK_SECRET
      ? "CASHFREE_WEBHOOK_SECRET"
      : null,
    data.PAYMENT_PROVIDER === "razorpay" && !data.RAZORPAY_KEY_ID
      ? "RAZORPAY_KEY_ID"
      : null,
    data.PAYMENT_PROVIDER === "razorpay" && !data.RAZORPAY_KEY_SECRET
      ? "RAZORPAY_KEY_SECRET"
      : null,
    data.PAYMENT_PROVIDER === "razorpay" && !data.RAZORPAY_WEBHOOK_SECRET
      ? "RAZORPAY_WEBHOOK_SECRET"
      : null,
    data.KYC_PROVIDER_BASE_URL ? null : "KYC_PROVIDER_BASE_URL",
    data.KYC_PROVIDER_API_KEY ? null : "KYC_PROVIDER_API_KEY",
    data.FIREBASE_PROJECT_ID ? null : "FIREBASE_PROJECT_ID",
    data.FIREBASE_CLIENT_EMAIL ? null : "FIREBASE_CLIENT_EMAIL",
    data.FIREBASE_PRIVATE_KEY ? null : "FIREBASE_PRIVATE_KEY",
    data.KYC_WEBHOOK_SECRET ? null : "KYC_WEBHOOK_SECRET",
    data.GOLD_RATE_WEBHOOK_SECRET ? null : "GOLD_RATE_WEBHOOK_SECRET",
  ].filter(Boolean);

  if (missing.length > 0) {
    throw new Error(
      `Invalid environment configuration: missing production live provider credentials ${missing.join(", ")}`,
    );
  }
}

function assertProductionNoTestCredentials(data: z.infer<typeof envSchema>) {
  const invalid: string[] = [];

  if (
    data.PAYMENT_PROVIDER === "razorpay" &&
    data.RAZORPAY_KEY_ID?.startsWith("rzp_test_")
  ) {
    invalid.push("RAZORPAY_KEY_ID must be a live key (rzp_live_*) in production");
  }

  const placeholderPattern = /^(YOUR_|REPLACE_ME|<|mock$|mock@)/i;
  const credentialFields: Array<[string, string | undefined]> = [
    ["RAZORPAY_KEY_SECRET", data.RAZORPAY_KEY_SECRET],
    ["MSG91_AUTH_KEY", data.MSG91_AUTH_KEY],
    ["KYC_PROVIDER_API_KEY", data.KYC_PROVIDER_API_KEY],
    ["S3_ACCESS_KEY_ID", data.S3_ACCESS_KEY_ID],
    ["S3_SECRET_ACCESS_KEY", data.S3_SECRET_ACCESS_KEY],
  ];

  for (const [name, value] of credentialFields) {
    if (value && placeholderPattern.test(value)) {
      invalid.push(`${name} must not use placeholder values in production`);
    }
  }

  if (invalid.length > 0) {
    throw new Error(
      `Invalid environment configuration: ${invalid.join("; ")}`,
    );
  }
}

function assertProductionInfrastructure(data: z.infer<typeof envSchema>) {
  const missing = [
    data.STORAGE_BACKEND === "s3" && !data.S3_BUCKET ? "S3_BUCKET" : null,
    data.STORAGE_BACKEND === "s3" && !data.S3_ACCESS_KEY_ID
      ? "S3_ACCESS_KEY_ID"
      : null,
    data.STORAGE_BACKEND === "s3" && !data.S3_SECRET_ACCESS_KEY
      ? "S3_SECRET_ACCESS_KEY"
      : null,
    data.STORAGE_BACKEND === "s3" && !data.S3_PUBLIC_BASE_URL
      ? "S3_PUBLIC_BASE_URL"
      : null,
    !data.CORS_ALLOWED_ORIGINS ? "CORS_ALLOWED_ORIGINS" : null,
    data.ENABLE_DEMO_SEEDS ? "ENABLE_DEMO_SEEDS must be false in production" : null,
  ].filter(Boolean);

  if (missing.length > 0) {
    throw new Error(
      `Invalid environment configuration: production infrastructure requirements not met (${missing.join(", ")})`,
    );
  }

  if (data.STORAGE_BACKEND !== "s3") {
    throw new Error(
      "Production requires STORAGE_BACKEND=s3 for durable KYC/media uploads",
    );
  }
}

export function parseCorsOrigins(origins: string | undefined): string[] {
  if (!origins?.trim()) {
    return [];
  }

  return origins
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}

export function loadEnv(input: NodeJS.ProcessEnv = process.env): Env {
  const parsed = envSchema.safeParse(input);

  if (!parsed.success) {
    const details = parsed.error.flatten().fieldErrors;
    throw new Error(
      `Invalid environment configuration: ${JSON.stringify(details)}`,
    );
  }

  const data = parsed.data;

  if (data.NODE_ENV === "production") {
    const missingSecrets = [
      data.JWT_SECRET ? null : "JWT_SECRET",
      data.JWT_REFRESH_SECRET ? null : "JWT_REFRESH_SECRET",
      data.OTP_HASH_SECRET ? null : "OTP_HASH_SECRET",
      data.PII_ENCRYPTION_SECRET ? null : "PII_ENCRYPTION_SECRET",
      data.ADMIN_JWT_SECRET ? null : "ADMIN_JWT_SECRET",
    ].filter(Boolean);

    if (missingSecrets.length > 0) {
      throw new Error(
        `Invalid environment configuration: missing production secrets ${missingSecrets.join(", ")}`,
      );
    }

    assertProductionProviderModes(data);
    assertProductionLiveCredentials(data);
    assertProductionNoTestCredentials(data);
    assertProductionInfrastructure(data);
  }

  // Staging must also have real secrets (no dev fallbacks) but may use
  // mock providers while infrastructure is being set up.
  if (data.NODE_ENV === "staging") {
    const missingSecrets = [
      data.JWT_SECRET ? null : "JWT_SECRET",
      data.JWT_REFRESH_SECRET ? null : "JWT_REFRESH_SECRET",
      data.OTP_HASH_SECRET ? null : "OTP_HASH_SECRET",
      data.PII_ENCRYPTION_SECRET ? null : "PII_ENCRYPTION_SECRET",
      data.ADMIN_JWT_SECRET ? null : "ADMIN_JWT_SECRET",
    ].filter(Boolean);

    if (missingSecrets.length > 0) {
      throw new Error(
        `Invalid environment configuration: staging requires real secrets. Missing: ${missingSecrets.join(", ")}`,
      );
    }
  }

  if (data.NODE_ENV !== "production" && data.NODE_ENV !== "test") {
    if (
      data.PAYMENT_PROVIDER_MODE === "live" &&
      data.PAYMENT_PROVIDER === "cashfree" &&
      (!data.CASHFREE_APP_ID || !data.CASHFREE_SECRET_KEY)
    ) {
      throw new Error(
        "PAYMENT_PROVIDER_MODE=live with PAYMENT_PROVIDER=cashfree requires CASHFREE_APP_ID and CASHFREE_SECRET_KEY",
      );
    }

    if (
      data.PAYMENT_PROVIDER_MODE === "live" &&
      data.PAYMENT_PROVIDER === "razorpay" &&
      (!data.RAZORPAY_KEY_ID || !data.RAZORPAY_KEY_SECRET)
    ) {
      throw new Error(
        "PAYMENT_PROVIDER_MODE=live with PAYMENT_PROVIDER=razorpay requires RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET",
      );
    }

    // Warn loudly if any secret is absent — the dev fallback strings are weak
    // and must never be used in a staging / preview environment.
    const usingFallback = [
      !data.JWT_SECRET && "JWT_SECRET",
      !data.JWT_REFRESH_SECRET && "JWT_REFRESH_SECRET",
      !data.OTP_HASH_SECRET && "OTP_HASH_SECRET",
      !data.PII_ENCRYPTION_SECRET && "PII_ENCRYPTION_SECRET",
      !data.ADMIN_JWT_SECRET && "ADMIN_JWT_SECRET",
    ].filter(Boolean);

    if (usingFallback.length > 0) {
      console.warn(
        `[env] WARNING: using insecure development fallback secrets for: ${usingFallback.join(", ")}. ` +
          "Set these env vars before exposing this server to a network.",
      );
    }
  }

  return {
    ...data,
    JWT_SECRET: data.JWT_SECRET ?? developmentSecrets.JWT_SECRET,
    JWT_REFRESH_SECRET:
      data.JWT_REFRESH_SECRET ?? developmentSecrets.JWT_REFRESH_SECRET,
    OTP_HASH_SECRET: data.OTP_HASH_SECRET ?? developmentSecrets.OTP_HASH_SECRET,
    PII_ENCRYPTION_SECRET:
      data.PII_ENCRYPTION_SECRET ?? developmentSecrets.PII_ENCRYPTION_SECRET,
    ADMIN_JWT_SECRET:
      data.ADMIN_JWT_SECRET ?? developmentSecrets.ADMIN_JWT_SECRET,
  };
}
