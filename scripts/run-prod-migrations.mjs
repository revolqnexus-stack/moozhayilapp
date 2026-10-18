/**
 * Apply Prisma migrations to the production Neon branch (PRODUCTION_ENV DATABASE_URL).
 */
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const API_DIR = path.join(ROOT, "apps/api");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");
const STAGING_ENV = path.join(ROOT, "STAGING_ENV.txt");

function parseEnv(content) {
  const vars = {};
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2];
  }
  return vars;
}

function host(url) {
  try {
    return new URL(url).hostname;
  } catch {
    return null;
  }
}

function main() {
  const prod = parseEnv(fs.readFileSync(PROD_ENV, "utf8"));
  const staging = fs.existsSync(STAGING_ENV)
    ? parseEnv(fs.readFileSync(STAGING_ENV, "utf8"))
    : {};

  if (!prod.DATABASE_URL) throw new Error("PRODUCTION_ENV.txt missing DATABASE_URL");
  if (staging.DATABASE_URL && prod.DATABASE_URL === staging.DATABASE_URL) {
    throw new Error("Production DATABASE_URL matches staging — run setup-step2-infrastructure.mjs first");
  }

  console.log(`Applying migrations to production Neon host: ${host(prod.DATABASE_URL) ?? "unknown"}`);
  try {
    execSync("npx prisma migrate deploy", {
      cwd: API_DIR,
      stdio: "pipe",
      env: { ...process.env, DATABASE_URL: prod.DATABASE_URL },
    });
    console.log("Production migrations complete.");
  } catch (err) {
    const out = `${err.stdout ?? ""}${err.stderr ?? ""}`;
    if (out.includes("already exists") || out.includes("P3018")) {
      console.log("Schema-only branch detected — baselining migration history instead...");
      execSync("node scripts/baseline-prod-migrations.mjs", {
        cwd: ROOT,
        stdio: "inherit",
      });
      return;
    }
    throw err;
  }
}

main();
