/**
 * Ensure active gold rates exist for all purities on production Neon.
 * Usage: node scripts/seed-prod-gold-rates.mjs
 */
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const API_DIR = path.join(ROOT, "apps/api");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");

function parseEnv(content) {
  const vars = {};
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2];
  }
  return vars;
}

function main() {
  const prod = parseEnv(fs.readFileSync(PROD_ENV, "utf8"));
  if (!prod.DATABASE_URL) throw new Error("PRODUCTION_ENV.txt missing DATABASE_URL");

  execSync("npx tsx scripts/seed-prod-gold-rates.ts", {
    cwd: API_DIR,
    stdio: "inherit",
    env: { ...process.env, DATABASE_URL: prod.DATABASE_URL },
  });
  console.log("Done. Gold-rate cache refreshes within ~60s.");
}

main();
