/**
 * Step 2: wire production Neon branch URL into PRODUCTION_ENV.txt,
 * copy staging secrets to STAGING_ENV.txt, update config/environments.json.
 *
 * Does NOT print secret values.
 */
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const NEON_PROJECT = "gentle-block-84894749";
const NEON_ORG = "org-mute-bird-84467257";
const PROD_BRANCH_ID = "br-damp-math-axi5dk1v";
const PROD_BRANCH_NAME = "moozhayil-prod";
const STAGING_BRANCH_NAME = "production";
const STAGING_ENV = path.join(ROOT, "STAGING_ENV.txt");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");
const ENV_CONFIG = path.join(ROOT, "config/environments.json");

function parseEnv(content) {
  const vars = {};
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2];
  }
  return vars;
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

function getNeonConnectionString(branchName) {
  const out = execSync(
    `npx neonctl connection-string ${branchName} --project-id ${NEON_PROJECT} --org-id ${NEON_ORG} --role neondb_owner --pooled`,
    { encoding: "utf8", cwd: ROOT },
  );
  const line = out
    .split(/\r?\n/)
    .map((l) => l.trim())
    .find((l) => l.startsWith("postgresql://"));
  if (!line) throw new Error(`No connection string for branch ${branchName}`);
  return line;
}

function neonHost(connectionString) {
  try {
    return new URL(connectionString).hostname;
  } catch {
    return null;
  }
}

function main() {
  if (!fs.existsSync(PROD_ENV)) {
    throw new Error("Missing PRODUCTION_ENV.txt");
  }

  const prodContent = fs.readFileSync(PROD_ENV, "utf8");
  const prodVars = parseEnv(prodContent);

  // Staging file = current live Render values (preserve staging).
  if (!fs.existsSync(STAGING_ENV)) {
    fs.writeFileSync(STAGING_ENV, prodContent);
    console.log("Created STAGING_ENV.txt from current env file.");
  }

  const stagingDbUrl = getNeonConnectionString(STAGING_BRANCH_NAME);
  const prodDbUrl = getNeonConnectionString(PROD_BRANCH_NAME);
  if (stagingDbUrl === prodDbUrl) {
    throw new Error(
      "Production and staging Neon connection strings are identical — aborting to prevent cross-environment DB use",
    );
  }

  const stagingVars = parseEnv(fs.readFileSync(STAGING_ENV, "utf8"));
  stagingVars.DATABASE_URL = stagingDbUrl;
  stagingVars.NODE_ENV = "staging";
  fs.writeFileSync(STAGING_ENV, serializeEnv(stagingVars, prodContent));

  prodVars.DATABASE_URL = prodDbUrl;
  prodVars.NODE_ENV = "production";
  prodVars.SMS_PROVIDER_MODE = "live";
  prodVars.KYC_PROVIDER_MODE = "live";
  prodVars.FIREBASE_MODE = "live";
  prodVars.PAYMENT_PROVIDER_MODE = "live";
  prodVars.STORAGE_BACKEND = "s3";
  prodVars.ENABLE_DEMO_SEEDS = "false";

  fs.writeFileSync(PROD_ENV, serializeEnv(prodVars, prodContent));
  console.log("Updated STAGING_ENV.txt and PRODUCTION_ENV.txt with branch-specific DATABASE_URL.");
  console.log(`  staging Neon host: ${neonHost(stagingDbUrl) ?? "unknown"}`);
  console.log(`  production Neon host: ${neonHost(prodDbUrl) ?? "unknown"}`);

  if (fs.existsSync(ENV_CONFIG)) {
    const cfg = JSON.parse(fs.readFileSync(ENV_CONFIG, "utf8"));
    cfg.staging.neonDatabaseHost = neonHost(stagingDbUrl);
    cfg.production.neonBranchId = PROD_BRANCH_ID;
    cfg.production.neonDatabaseHost = neonHost(prodDbUrl);
    fs.writeFileSync(ENV_CONFIG, JSON.stringify(cfg, null, 2) + "\n");
  }
}

main();
