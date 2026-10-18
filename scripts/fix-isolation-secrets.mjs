/**
 * Fix staging/production secret isolation:
 * - Generate production-only PII_ENCRYPTION_SECRET (staging unchanged)
 * - Point staging Firebase at mock placeholders (prod Firebase stays live)
 * - Remove prod R2 bucket name from staging env file
 *
 * Does not print secret values.
 */
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");
const STAGING_ENV = path.join(ROOT, "STAGING_ENV.txt");

function replaceEnvKey(content, key, value) {
  const re = new RegExp(`^${key}=.*$`, "m");
  return re.test(content) ? content.replace(re, `${key}=${value}`) : `${content}\n${key}=${value}`;
}

function main() {
  if (!fs.existsSync(PROD_ENV) || !fs.existsSync(STAGING_ENV)) {
    throw new Error("Missing PRODUCTION_ENV.txt or STAGING_ENV.txt");
  }

  let prod = fs.readFileSync(PROD_ENV, "utf8");
  let staging = fs.readFileSync(STAGING_ENV, "utf8");

  const prodPii = crypto.randomBytes(32).toString("hex");
  prod = replaceEnvKey(prod, "PII_ENCRYPTION_SECRET", prodPii);

  staging = replaceEnvKey(staging, "FIREBASE_MODE", "mock");
  staging = replaceEnvKey(staging, "FIREBASE_PROJECT_ID", "mock-staging");
  staging = replaceEnvKey(staging, "FIREBASE_CLIENT_EMAIL", "mock@staging.moozhayil.local");
  staging = replaceEnvKey(staging, "FIREBASE_PRIVATE_KEY", "mock");
  staging = replaceEnvKey(staging, "STORAGE_BACKEND", "local");
  staging = replaceEnvKey(staging, "S3_BUCKET", "staging-local-unused");
  staging = replaceEnvKey(staging, "S3_ENDPOINT", "");
  staging = replaceEnvKey(staging, "S3_ACCESS_KEY_ID", "");
  staging = replaceEnvKey(staging, "S3_SECRET_ACCESS_KEY", "");
  staging = replaceEnvKey(staging, "S3_PUBLIC_BASE_URL", "");

  fs.writeFileSync(PROD_ENV, prod);
  fs.writeFileSync(STAGING_ENV, staging);

  console.log("Isolation fixes applied:");
  console.log("  - PRODUCTION_ENV.txt: new PII_ENCRYPTION_SECRET (prod-only)");
  console.log("  - STAGING_ENV.txt: mock Firebase, local storage, no prod R2 bucket");
  console.log("");
  console.log("Next:");
  console.log("  powershell -File scripts/push-render-staging-env.ps1");
  console.log("  powershell -File scripts/push-render-production-env.ps1 -Prelaunch");
}

main();
