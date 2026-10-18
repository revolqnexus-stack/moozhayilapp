/**
 * Create a dedicated Upstash Redis database for production and wire REDIS_URL
 * into PRODUCTION_ENV.txt. Staging REDIS_URL is never modified.
 *
 * Credentials (gitignored): .upstash-credentials.json
 *   { "email": "you@example.com", "apiKey": "..." }
 * Or env: UPSTASH_EMAIL + UPSTASH_API_KEY
 *
 * Does not print secret values.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");
const STAGING_ENV = path.join(ROOT, "STAGING_ENV.txt");
const ENV_CONFIG = path.join(ROOT, "config/environments.json");
const CREDS_FILE = path.join(ROOT, ".upstash-credentials.json");
const DB_NAME = "moozhayil-prod";

function parseEnv(content) {
  const vars = {};
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2];
  }
  return vars;
}

function redisHost(redisUrl) {
  try {
    return new URL(redisUrl).hostname;
  } catch {
    return null;
  }
}

function serializeEnv(vars, templateContent) {
  const lines = templateContent.split(/\r?\n/);
  return lines
    .map((line) => {
      const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
      if (!m) return line;
      const key = m[1];
      if (vars[key] !== undefined) return `${key}=${vars[key]}`;
      return line;
    })
    .join("\n");
}

function loadCredentials() {
  if (process.env.UPSTASH_EMAIL && process.env.UPSTASH_API_KEY) {
    return {
      email: process.env.UPSTASH_EMAIL,
      apiKey: process.env.UPSTASH_API_KEY,
    };
  }
  if (fs.existsSync(CREDS_FILE)) {
    const parsed = JSON.parse(fs.readFileSync(CREDS_FILE, "utf8"));
    if (parsed.email && parsed.apiKey) return parsed;
  }
  return null;
}

function basicAuth(email, apiKey) {
  return `Basic ${Buffer.from(`${email}:${apiKey}`).toString("base64")}`;
}

async function listDatabases(creds) {
  const res = await fetch("https://api.upstash.com/v2/redis/databases", {
    headers: { Authorization: basicAuth(creds.email, creds.apiKey) },
  });
  if (!res.ok) {
    throw new Error(`Upstash list databases failed: ${res.status}`);
  }
  const body = await res.json();
  return Array.isArray(body) ? body : (body.result ?? body.databases ?? []);
}

async function createDatabase(creds) {
  const res = await fetch("https://api.upstash.com/v2/redis/database", {
    method: "POST",
    headers: {
      Authorization: basicAuth(creds.email, creds.apiKey),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      name: DB_NAME,
      database_name: DB_NAME,
      region: "us-east-1",
      tls: true,
    }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Upstash create database failed: ${res.status} ${text.slice(0, 200)}`);
  }
  return res.json();
}

function toRedisUrl(db) {
  if (db.redis_url) return db.redis_url;
  const password = db.password ?? db.token;
  let host = db.endpoint ?? db.host ?? "";
  host = host.replace(/^https?:\/\//, "").split("/")[0];
  if (!host.includes(".upstash.io") && db.database_id) {
    host = `${db.database_id}.upstash.io`;
  }
  if (host && password) {
    return `rediss://default:${password}@${host}:6379`;
  }
  throw new Error("Could not derive REDIS_URL from Upstash response");
}

async function main() {
  const creds = loadCredentials();
  if (!creds) {
    console.log(
      "Skip: no Upstash Developer API credentials (.upstash-credentials.json or UPSTASH_EMAIL/UPSTASH_API_KEY).",
    );
    console.log("Create production Redis manually in Upstash console, then update PRODUCTION_ENV.txt REDIS_URL.");
    process.exit(0);
  }

  if (!fs.existsSync(PROD_ENV)) {
    throw new Error("Missing PRODUCTION_ENV.txt");
  }

  const stagingHost = fs.existsSync(STAGING_ENV)
    ? redisHost(parseEnv(fs.readFileSync(STAGING_ENV, "utf8")).REDIS_URL ?? "")
    : null;

  let db = (await listDatabases(creds)).find(
    (item) => item.name === DB_NAME || item.database_name === DB_NAME,
  );
  if (!db) {
    console.log(`Creating Upstash Redis database "${DB_NAME}"...`);
    db = await createDatabase(creds);
  } else {
    console.log(`Reusing existing Upstash Redis database "${DB_NAME}".`);
  }

  const redisUrl = toRedisUrl(db);
  const prodHost = redisHost(redisUrl);
  if (stagingHost && prodHost === stagingHost) {
    throw new Error(
      "Production REDIS_URL host matches staging — aborting to prevent cross-environment Redis use",
    );
  }

  const prodContent = fs.readFileSync(PROD_ENV, "utf8");
  const prodVars = parseEnv(prodContent);
  prodVars.REDIS_URL = redisUrl;
  fs.writeFileSync(PROD_ENV, serializeEnv(prodVars, prodContent));
  console.log(`Updated PRODUCTION_ENV.txt REDIS_URL (host: ${prodHost ?? "unknown"}).`);

  if (fs.existsSync(ENV_CONFIG)) {
    const cfg = JSON.parse(fs.readFileSync(ENV_CONFIG, "utf8"));
    if (stagingHost) cfg.staging.redisHost = stagingHost;
    cfg.production.redisHost = prodHost;
    fs.writeFileSync(ENV_CONFIG, JSON.stringify(cfg, null, 2) + "\n");
  }
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
