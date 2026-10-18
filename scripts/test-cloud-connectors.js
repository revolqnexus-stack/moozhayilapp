/* eslint-disable @typescript-eslint/no-require-imports */
const { PrismaClient } = require("@prisma/client");
const Redis = require("ioredis");

async function main() {
  const databaseUrl = process.env.DATABASE_URL;
  const redisUrl = process.env.REDIS_URL;

  if (!databaseUrl || !redisUrl) {
    console.error("missing_env: DATABASE_URL and REDIS_URL required");
    process.exit(1);
  }

  const prisma = new PrismaClient({
    datasources: { db: { url: databaseUrl } },
  });

  try {
    await prisma.$queryRaw`SELECT 1 as ok`;
    console.log("neon_ok");
  } catch (error) {
    console.error("neon_fail:", error instanceof Error ? error.message : error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }

  const redis = new Redis(redisUrl, {
    maxRetriesPerRequest: 1,
    connectTimeout: 15000,
  });

  try {
    const pong = await redis.ping();
    if (pong !== "PONG") {
      throw new Error(`unexpected ping response: ${pong}`);
    }
    console.log("redis_ok");
  } catch (error) {
    console.error("redis_fail:", error instanceof Error ? error.message : error);
    process.exit(1);
  } finally {
    await redis.quit();
  }
}

main();
