/**
 * Ensure active gold rates exist for all purities (production bootstrap).
 * Usage: DATABASE_URL=... npx tsx scripts/seed-prod-gold-rates.ts
 */
import fs from "fs";
import path from "path";
import { PrismaClient, type Purity } from "@prisma/client";

function readDatabaseUrl(): string {
  if (process.env.DATABASE_URL?.trim()) {
    return process.env.DATABASE_URL.trim();
  }

  const prodEnv = path.join(__dirname, "..", "..", "..", "PRODUCTION_ENV.txt");
  if (fs.existsSync(prodEnv)) {
    for (const line of fs.readFileSync(prodEnv, "utf8").split(/\r?\n/)) {
      if (line.startsWith("DATABASE_URL=")) {
        return line.slice("DATABASE_URL=".length).trim();
      }
    }
  }

  throw new Error("DATABASE_URL not found in environment or PRODUCTION_ENV.txt");
}

const GOLD_RATES_PAISE: Record<Purity, number> = {
  k14: 380000,
  k18: 495000,
  k22: 624000,
  k24: 680000,
};

const prisma = new PrismaClient({
  datasources: { db: { url: readDatabaseUrl() } },
});

async function main() {
  const now = new Date();
  for (const [purity, ratePerGramPaise] of Object.entries(GOLD_RATES_PAISE) as [
    Purity,
    number,
  ][]) {
    const existing = await prisma.goldRateHistory.findFirst({
      where: { purity, effectiveTo: null },
    });
    if (existing) {
      console.log(`skip ${purity} @ ${existing.ratePerGramPaise} paise/g`);
      continue;
    }
    await prisma.goldRateHistory.create({
      data: {
        purity,
        ratePerGramPaise,
        effectiveFrom: now,
        source: "prod_bootstrap",
      },
    });
    console.log(`created ${purity} @ ${ratePerGramPaise} paise/g`);
  }
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
