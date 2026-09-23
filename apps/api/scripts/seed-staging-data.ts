/**
 * Seeds gold rates + demo catalog on Neon without full loadEnv validation.
 * Usage (from apps/api):
 *   npx tsx scripts/seed-staging-data.ts
 * Requires DATABASE_URL in apps/api/.env.cloud or environment.
 */
import fs from "fs";
import path from "path";
import { PrismaClient, Purity, ProductImageType } from "@prisma/client";

function readDatabaseUrl(): string {
  if (process.env.DATABASE_URL?.trim()) {
    return process.env.DATABASE_URL.trim();
  }

  const envPath = path.join(__dirname, "..", ".env.cloud");
  const content = fs.readFileSync(envPath, "utf8");
  for (const line of content.split(/\r?\n/)) {
    if (line.startsWith("DATABASE_URL=")) {
      return line.slice("DATABASE_URL=".length).trim();
    }
  }

  throw new Error("DATABASE_URL not found in environment or .env.cloud");
}

const prisma = new PrismaClient({
  datasources: { db: { url: readDatabaseUrl() } },
});

const PRODUCT_IMAGE =
  "https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=800&q=80";

const GOLD_RATES_PAISE: Record<Purity, number> = {
  k14: 380000,
  k18: 495000,
  k22: 624000,
  k24: 680000,
};

const DEMO_PRODUCTS = [
  {
    sku: "MZ-NK-001",
    name: "Temple Bloom Necklace",
    description: "22k gold necklace with temple-inspired detailing.",
    weightGrams: "8.5000",
    makingChargePct: "12.00",
    stockQuantity: 5,
    isFeatured: true,
  },
  {
    sku: "MZ-RG-002",
    name: "Heritage Band Ring",
    description: "Classic 22k band ring for everyday elegance.",
    weightGrams: "4.2000",
    makingChargePct: "10.00",
    stockQuantity: 8,
    isFeatured: true,
  },
  {
    sku: "MZ-BG-003",
    name: "Kerala Kasu Bangle",
    description: "Traditional kasu bangle pair in 22k gold.",
    weightGrams: "12.0000",
    makingChargePct: "11.00",
    stockQuantity: 4,
    isFeatured: true,
  },
] as const;

async function seedGoldRates() {
  const now = new Date();
  for (const [purity, ratePerGramPaise] of Object.entries(GOLD_RATES_PAISE)) {
    const existing = await prisma.goldRateHistory.findFirst({
      where: { purity: purity as Purity, effectiveTo: null },
    });

    if (existing) {
      console.log(`Gold rate exists: ${purity} @ ${existing.ratePerGramPaise}`);
      continue;
    }

    await prisma.goldRateHistory.create({
      data: {
        purity: purity as Purity,
        ratePerGramPaise,
        effectiveFrom: now,
        source: "staging_seed",
      },
    });
    console.log(`Created gold rate: ${purity} @ ${ratePerGramPaise} paise/g`);
  }
}

async function seedCatalog() {
  let category = await prisma.category.findUnique({ where: { slug: "necklaces" } });
  if (!category) {
    category = await prisma.category.create({
      data: {
        name: "Necklaces",
        slug: "necklaces",
        sortOrder: 0,
        isActive: true,
      },
    });
  }

  let collection = await prisma.collection.findUnique({
    where: { slug: "onam-2026" },
  });
  if (!collection) {
    collection = await prisma.collection.create({
      data: {
        name: "Onam 2026",
        slug: "onam-2026",
        description: "Festive pieces for Onam celebrations.",
        coverImageUrl: PRODUCT_IMAGE,
        isActive: true,
        isFeatured: true,
        sortOrder: 0,
      },
    });
  }

  let occasion = await prisma.occasion.findUnique({ where: { slug: "wedding" } });
  if (!occasion) {
    occasion = await prisma.occasion.create({
      data: { name: "Wedding", slug: "wedding", isActive: true, sortOrder: 0 },
    });
  }

  for (const demo of DEMO_PRODUCTS) {
    const existing = await prisma.product.findUnique({ where: { sku: demo.sku } });
    if (existing) {
      console.log(`Product exists: ${demo.sku}`);
      continue;
    }

    await prisma.product.create({
      data: {
        sku: demo.sku,
        name: demo.name,
        description: demo.description,
        categoryId: category.id,
        collectionId: collection.id,
        purity: Purity.k22,
        weightGrams: demo.weightGrams,
        makingChargePct: demo.makingChargePct,
        stockQuantity: demo.stockQuantity,
        isPublished: true,
        isFeatured: demo.isFeatured,
        images: {
          create: {
            s3Key: `catalog/${demo.sku}.jpg`,
            cdnUrl: PRODUCT_IMAGE,
            type: ProductImageType.white_background,
            sortOrder: 0,
            isPrimary: true,
          },
        },
        occasionTags: { create: { occasionId: occasion.id } },
      },
    });
    console.log(`Created product: ${demo.name}`);
  }
}

async function main() {
  await seedGoldRates();
  await seedCatalog();
  console.log("Staging seed complete.");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
