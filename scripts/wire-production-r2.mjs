/**
 * Wire Cloudflare R2 S3 credentials into PRODUCTION_ENV.txt.
 *
 * Usage:
 *   S3_ACCESS_KEY_ID=... S3_SECRET_ACCESS_KEY=... node scripts/wire-production-r2.mjs
 *
 * Optional:
 *   S3_PUBLIC_BASE_URL=https://pub-xxxxx.r2.dev
 */
import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");
const ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID ?? "28247e5c8e5aca83c94a869bdfbd0b6d";
const BUCKET = process.env.R2_BUCKET_NAME ?? "moozhayil-media";

const accessKeyId = process.env.S3_ACCESS_KEY_ID?.trim();
const secretAccessKey = process.env.S3_SECRET_ACCESS_KEY?.trim();
const publicBaseUrl = process.env.S3_PUBLIC_BASE_URL?.trim();

if (!accessKeyId || !secretAccessKey) {
  throw new Error("Set S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY");
}

function parseEnv(content) {
  const vars = {};
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2];
  }
  return vars;
}

function serializeEnv(vars, templateContent) {
  return templateContent
    .split(/\r?\n/)
    .map((line) => {
      const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
      if (!m) return line;
      const key = m[1];
      return vars[key] !== undefined ? `${key}=${vars[key]}` : line;
    })
    .join("\n");
}

async function testR2() {
  const require = createRequire(path.join(ROOT, "apps/api/package.json"));
  const { S3Client, PutObjectCommand, GetObjectCommand } = require("@aws-sdk/client-s3");
  const client = new S3Client({
    region: "auto",
    endpoint: `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: { accessKeyId, secretAccessKey },
  });
  const key = `test/wire-${Date.now()}.txt`;
  const body = `wire-test-${new Date().toISOString()}`;
  await client.send(
    new PutObjectCommand({ Bucket: BUCKET, Key: key, Body: body, ContentType: "text/plain" }),
  );
  const got = await client.send(new GetObjectCommand({ Bucket: BUCKET, Key: key }));
  const text = await got.Body.transformToString();
  if (text !== body) throw new Error("R2 readback mismatch");
}

async function main() {
  await testR2();

  const prodContent = fs.readFileSync(PROD_ENV, "utf8");
  const prodVars = parseEnv(prodContent);
  prodVars.STORAGE_BACKEND = "s3";
  prodVars.S3_ENDPOINT = `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`;
  prodVars.S3_REGION = "auto";
  prodVars.S3_BUCKET = BUCKET;
  prodVars.S3_ACCESS_KEY_ID = accessKeyId;
  prodVars.S3_SECRET_ACCESS_KEY = secretAccessKey;
  prodVars.S3_FORCE_PATH_STYLE = "false";
  if (publicBaseUrl) {
    prodVars.S3_PUBLIC_BASE_URL = publicBaseUrl.replace(/\/$/, "");
  }

  fs.writeFileSync(PROD_ENV, serializeEnv(prodVars, prodContent));
  console.log("R2 credentials verified and PRODUCTION_ENV.txt updated.");
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
