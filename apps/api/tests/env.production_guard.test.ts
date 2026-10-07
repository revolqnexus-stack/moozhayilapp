import { loadEnv } from "../src/config/env";

const productionSecrets = {
  JWT_SECRET: "prod_jwt_secret_at_least_32_characters",
  JWT_REFRESH_SECRET: "prod_refresh_secret_at_least_32_chars",
  OTP_HASH_SECRET: "prod_otp_hash_secret_at_least_32_chars",
  PII_ENCRYPTION_SECRET: "prod_pii_encryption_secret_32_chars",
  ADMIN_JWT_SECRET: "prod_admin_jwt_secret_at_least_32_chars",
};

const productionBase = {
  NODE_ENV: "production",
  DATABASE_URL: "postgresql://user:pass@localhost:5432/moozhayil",
  REDIS_URL: "redis://localhost:6379",
  ...productionSecrets,
  SMS_PROVIDER_MODE: "live",
  PAYMENT_PROVIDER_MODE: "live",
  KYC_PROVIDER_MODE: "live",
  FIREBASE_MODE: "live",
  STORAGE_BACKEND: "s3",
  S3_BUCKET: "moozhayil-media",
  S3_ACCESS_KEY_ID: "test_access_key",
  S3_SECRET_ACCESS_KEY: "test_secret_key",
  S3_PUBLIC_BASE_URL: "https://cdn.example.com",
  CORS_ALLOWED_ORIGINS: "https://app.example.com",
  MSG91_AUTH_KEY: "test_msg91_key",
  MSG91_OTP_TEMPLATE_ID: "test_template",
  MSG91_DLT_PE_ID: "1001435730734881903",
  MSG91_DLT_TE_ID: "1077188560121746406",
  RAZORPAY_KEY_ID: "rzp_live_test_key_id",
  RAZORPAY_KEY_SECRET: "rzp_secret",
  RAZORPAY_WEBHOOK_SECRET: "webhook_secret",
  KYC_PROVIDER_BASE_URL: "https://kyc.example.com",
  KYC_PROVIDER_API_KEY: "kyc_api_key",
  KYC_WEBHOOK_SECRET: "kyc_webhook_secret",
  GOLD_RATE_WEBHOOK_SECRET: "gold_webhook_secret",
  FIREBASE_PROJECT_ID: "moozhayil-prod",
  FIREBASE_CLIENT_EMAIL: "firebase@moozhayil.com",
  FIREBASE_PRIVATE_KEY: "firebase_private_key",
};

describe("Production environment guards", () => {
  it("rejects SMS_PROVIDER_MODE=mock when NODE_ENV=production", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        SMS_PROVIDER_MODE: "mock",
      }),
    ).toThrow("Production requires live provider modes. Mock modes detected: SMS_PROVIDER_MODE");
  });

  it("allows SMS_PROVIDER_MODE=mock when NODE_ENV=staging", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        NODE_ENV: "staging",
        SMS_PROVIDER_MODE: "mock",
        PAYMENT_PROVIDER_MODE: "mock",
        KYC_PROVIDER_MODE: "mock",
        FIREBASE_MODE: "mock",
        STORAGE_BACKEND: "local",
      }),
    ).not.toThrow();
  });

  it("rejects Razorpay test keys when NODE_ENV=production", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        RAZORPAY_KEY_ID: "rzp_test_abc123",
      }),
    ).toThrow("RAZORPAY_KEY_ID must be a live key");
  });

  it("rejects staging Neon endpoint when MOOZHAYIL_STAGING_DATABASE_HOST is set", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        DATABASE_URL:
          "postgresql://user:pass@staging-neon.example.com/neondb?sslmode=require",
        MOOZHAYIL_STAGING_DATABASE_HOST: "staging-neon.example.com",
      }),
    ).toThrow("Production DATABASE_URL must not use staging Neon endpoint");
  });

  it("rejects staging Redis host when MOOZHAYIL_STAGING_REDIS_HOST is set", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        REDIS_URL: "redis://default:token@staging-redis.example.com:6379",
        MOOZHAYIL_STAGING_REDIS_HOST: "staging-redis.example.com",
      }),
    ).toThrow("Production REDIS_URL must not use staging Redis host");
  });

  it("allows mock KYC in production when MOOZHAYIL_ALLOW_MOCK_KYC is true", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        KYC_PROVIDER_MODE: "mock",
        MOOZHAYIL_ALLOW_MOCK_KYC: "true",
        KYC_PROVIDER_BASE_URL: undefined,
        KYC_PROVIDER_API_KEY: undefined,
      }),
    ).not.toThrow();
  });

  it("requires MSG91 credentials when NODE_ENV=production and SMS is live", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        SMS_PROVIDER_MODE: "live",
        MSG91_AUTH_KEY: undefined,
        MSG91_OTP_TEMPLATE_ID: undefined,
        MSG91_DLT_PE_ID: undefined,
        MSG91_DLT_TE_ID: undefined,
      }),
    ).toThrow(
      "missing production live provider credentials MSG91_AUTH_KEY, MSG91_OTP_TEMPLATE_ID, MSG91_DLT_PE_ID, MSG91_DLT_TE_ID",
    );
  });

  it("rejects Brand DLT ID used as MSG91_DLT_PE_ID", () => {
    expect(() =>
      loadEnv({
        ...productionBase,
        MSG91_DLT_PE_ID: "1016720216615695729",
      }),
    ).toThrow("MSG91_DLT_PE_ID is the Brand DLT ID");
  });
});
