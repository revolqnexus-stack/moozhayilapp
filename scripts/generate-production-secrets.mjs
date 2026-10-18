/**
 * Generate production-only auth secrets in PRODUCTION_ENV.txt.
 * STAGING_ENV.txt is never modified (staging Render keeps its own secrets).
 */
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");

const ROTATE_KEYS = [
  "JWT_SECRET",
  "JWT_REFRESH_SECRET",
  "OTP_HASH_SECRET",
  "PII_ENCRYPTION_SECRET",
  "ADMIN_JWT_SECRET",
  "KYC_WEBHOOK_SECRET",
  "GOLD_RATE_WEBHOOK_SECRET",
  "RAZORPAY_WEBHOOK_SECRET",
];

function main() {
  if (!fs.existsSync(PROD_ENV)) {
    throw new Error("Missing PRODUCTION_ENV.txt");
  }
  let content = fs.readFileSync(PROD_ENV, "utf8");
  for (const key of ROTATE_KEYS) {
    const value = crypto.randomBytes(32).toString("hex");
    const re = new RegExp(`^${key}=.*$`, "m");
    content = re.test(content)
      ? content.replace(re, `${key}=${value}`)
      : `${content}\n${key}=${value}`;
  }
  fs.writeFileSync(PROD_ENV, content);
  console.log(`Generated production-only secrets in PRODUCTION_ENV.txt (${ROTATE_KEYS.length} keys).`);
}

main();
