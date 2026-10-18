/**
 * Wire production REDIS_URL from env vars (never commit secrets).
 * Usage:
 *   UPSTASH_REDIS_HOST=frank-kodiak-285964.upstash.io UPSTASH_REDIS_TOKEN=... node scripts/wire-production-redis.mjs
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");
const ENV_CONFIG = path.join(ROOT, "config/environments.json");

const host = process.env.UPSTASH_REDIS_HOST?.trim();
const token = process.env.UPSTASH_REDIS_TOKEN?.trim();

if (!host || !token) {
  throw new Error("Set UPSTASH_REDIS_HOST and UPSTASH_REDIS_TOKEN");
}

const redisUrl = `rediss://default:${token}@${host}:6379`;

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

const prodContent = fs.readFileSync(PROD_ENV, "utf8");
const prodVars = parseEnv(prodContent);
prodVars.REDIS_URL = redisUrl;
fs.writeFileSync(PROD_ENV, serializeEnv(prodVars, prodContent));

let stagingHost = null;
if (fs.existsSync(ENV_CONFIG)) {
  const cfg = JSON.parse(fs.readFileSync(ENV_CONFIG, "utf8"));
  stagingHost = cfg.staging?.redisHost ?? null;
  cfg.production.redisHost = host;
  fs.writeFileSync(ENV_CONFIG, JSON.stringify(cfg, null, 2) + "\n");
}

console.log(`Updated PRODUCTION_ENV.txt REDIS_URL (host: ${host})`);
console.log(`Isolated from staging: ${stagingHost ? host !== stagingHost : "unknown"}`);
