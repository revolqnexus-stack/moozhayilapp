/**
 * Rotate compromised staging secrets on Render (safe subset).
 *
 * Rotates: JWT_*, OTP_HASH, ADMIN_JWT, KYC_WEBHOOK, GOLD_RATE_WEBHOOK, Firebase SA key
 * Preserves: PII_ENCRYPTION_SECRET, DATABASE_URL, REDIS_URL (require manual Neon/Upstash rotation)
 *
 * Usage: node scripts/rotate-staging-secrets.mjs
 */
import crypto from "crypto";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { createRequire } from "module";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const ENV_FILE = path.join(ROOT, "PRODUCTION_ENV.txt");
const KEY_FILE = path.join(ROOT, ".render-api-key");
const SERVICE_ID = "srv-dammuh61egvs73csp3ng";

const ROTATE_KEYS = [
  "JWT_SECRET",
  "JWT_REFRESH_SECRET",
  "OTP_HASH_SECRET",
  "ADMIN_JWT_SECRET",
  "KYC_WEBHOOK_SECRET",
  "GOLD_RATE_WEBHOOK_SECRET",
];

const PRESERVE_KEYS = ["PII_ENCRYPTION_SECRET", "DATABASE_URL", "REDIS_URL"];

function generateSecret() {
  return crypto.randomBytes(32).toString("hex");
}

function parseEnvFile(content) {
  const vars = {};
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2];
  }
  return vars;
}

function updateEnvFile(vars) {
  let content = fs.readFileSync(ENV_FILE, "utf8");
  for (const [key, value] of Object.entries(vars)) {
    const re = new RegExp(`^${key}=.*$`, "m");
    content = re.test(content)
      ? content.replace(re, `${key}=${value}`)
      : `${content}\n${key}=${value}`;
  }
  fs.writeFileSync(ENV_FILE, content);
}

async function pushToRender(apiKey, updates) {
  const headers = {
    Authorization: `Bearer ${apiKey}`,
    Accept: "application/json",
    "Content-Type": "application/json",
  };
  for (const [key, value] of Object.entries(updates)) {
    const res = await fetch(
      `https://api.render.com/v1/services/${SERVICE_ID}/env-vars/${key}`,
      { method: "PUT", headers, body: JSON.stringify({ value }) },
    );
    if (!res.ok) {
      throw new Error(`Render update failed for ${key}: ${res.status}`);
    }
    console.log(`  Render: rotated ${key}`);
  }
}

async function rotateFirebaseKey() {
  const require = createRequire(import.meta.url);
  const firebaseToolsRoot = path.join(
    path.dirname(process.execPath),
    "node_modules",
    "firebase-tools",
  );
  const auth = require(path.join(firebaseToolsRoot, "lib/auth"));
  const scopes = require(path.join(firebaseToolsRoot, "lib/scopes"));
  const PROJECT_ID = "moozhayil-prod";

  const account = auth.getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    console.log("  Firebase: skipped (CLI not logged in)");
    return null;
  }

  const tokens = await auth.getAccessToken(account.tokens.refresh_token, [
    scopes.CLOUD_PLATFORM,
  ]);
  const accessToken = tokens.access_token;

  const listRes = await fetch(
    `https://iam.googleapis.com/v1/projects/${PROJECT_ID}/serviceAccounts`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  const listData = await listRes.json();
  const email = listData.accounts?.find((a) =>
    a.email?.includes("firebase-adminsdk"),
  )?.email;
  if (!email) {
    console.log("  Firebase: skipped (no adminsdk account)");
    return null;
  }

  const createRes = await fetch(
    `https://iam.googleapis.com/v1/projects/${PROJECT_ID}/serviceAccounts/${encodeURIComponent(email)}/keys`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    },
  );
  if (!createRes.ok) {
    console.log("  Firebase: key creation failed — rotate manually in console");
    return null;
  }

  const keyData = await createRes.json();
  const creds = JSON.parse(
    Buffer.from(keyData.privateKeyData, "base64").toString("utf8"),
  );
  const saPath = path.join(ROOT, "apps/api/firebase-service-account.json");
  fs.writeFileSync(saPath, JSON.stringify(creds, null, 2));
  console.log("  Firebase: new service account key saved (gitignored)");

  return {
    FIREBASE_MODE: "live",
    FIREBASE_PROJECT_ID: creds.project_id,
    FIREBASE_CLIENT_EMAIL: creds.client_email,
    FIREBASE_PRIVATE_KEY: creds.private_key.replace(/\n/g, "\\n"),
  };
}

async function main() {
  if (!fs.existsSync(ENV_FILE)) {
    throw new Error("Missing PRODUCTION_ENV.txt (local gitignored file)");
  }
  if (!fs.existsSync(KEY_FILE)) {
    throw new Error("Missing .render-api-key");
  }

  const existing = parseEnvFile(fs.readFileSync(ENV_FILE, "utf8"));
  const updates = {};

  for (const key of ROTATE_KEYS) {
    updates[key] = generateSecret();
  }

  for (const key of PRESERVE_KEYS) {
    if (existing[key]) {
      console.log(`  Preserved ${key} (manual rotation required if compromised)`);
    }
  }

  console.log("Rotating Firebase credentials...");
  const firebaseUpdates = await rotateFirebaseKey();
  if (firebaseUpdates) {
    Object.assign(updates, firebaseUpdates);
  }

  console.log("Updating local PRODUCTION_ENV.txt...");
  updateEnvFile(updates);

  console.log("Pushing rotated secrets to Render staging...");
  const apiKey = fs.readFileSync(KEY_FILE, "utf8").trim();
  await pushToRender(apiKey, updates);

  console.log("\nDone. Staging users will need to log in again.");
  console.log("Manual rotation still required: Neon DB password, Upstash Redis token, Razorpay test secret.");
}

main().catch((err) => {
  console.error("ERROR:", err.message);
  process.exit(1);
});
