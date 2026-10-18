/**
 * Mark all Prisma migrations as applied on the production Neon branch.
 * Use when the branch was created schema-only (structure copied, no staging data).
 */
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const API_DIR = path.join(ROOT, "apps/api");
const MIGRATIONS_DIR = path.join(API_DIR, "prisma/migrations");
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

  const migrations = fs
    .readdirSync(MIGRATIONS_DIR, { withFileTypes: true })
    .filter((d) => d.isDirectory())
    .map((d) => d.name)
    .sort();

  console.log(`Marking ${migrations.length} migrations as applied on production branch...`);
  for (const name of migrations) {
    try {
      execSync(`npx prisma migrate resolve --applied ${name}`, {
        cwd: API_DIR,
        stdio: "pipe",
        env: { ...process.env, DATABASE_URL: prod.DATABASE_URL },
      });
      console.log(`  applied ${name}`);
    } catch (err) {
      const out = `${err.stdout ?? ""}${err.stderr ?? ""}`;
      if (out.includes("P3008")) {
        console.log(`  skip ${name} (already applied)`);
        continue;
      }
      if (out.includes("P3012")) {
        execSync(`npx prisma migrate resolve --rolled-back ${name}`, {
          cwd: API_DIR,
          stdio: "pipe",
          env: { ...process.env, DATABASE_URL: prod.DATABASE_URL },
        });
        execSync(`npx prisma migrate resolve --applied ${name}`, {
          cwd: API_DIR,
          stdio: "pipe",
          env: { ...process.env, DATABASE_URL: prod.DATABASE_URL },
        });
        console.log(`  recovered ${name}`);
        continue;
      }
      throw err;
    }
  }
  console.log("Production migration history baselined.");
}

main();
