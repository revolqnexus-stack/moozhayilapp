/**
 * Clears OTP/auth rate-limit keys from Upstash Redis (staging QA reset).
 * Usage: node scripts/clear-staging-rate-limits.js
 */
const path = require("path");
const Redis = require(path.join(
  __dirname,
  "..",
  "apps",
  "api",
  "node_modules",
  "ioredis",
));

require("dotenv").config({
  path: path.join(__dirname, "..", "apps", "api", ".env.cloud"),
});

async function main() {
  const redisUrl = process.env.REDIS_URL;
  if (!redisUrl) {
    throw new Error("REDIS_URL missing in apps/api/.env.cloud");
  }

  const redis = new Redis(redisUrl, {
    maxRetriesPerRequest: 1,
  });

  const patterns = ["rate:*send-otp*", "rate:*verify-otp*", "rate:public_ip:*"];
  let deleted = 0;

  for (const pattern of patterns) {
    let cursor = "0";
    do {
      const [nextCursor, keys] = await redis.scan(
        cursor,
        "MATCH",
        pattern,
        "COUNT",
        100,
      );
      cursor = nextCursor;
      if (keys.length > 0) {
        deleted += await redis.del(...keys);
      }
    } while (cursor !== "0");
  }

  await redis.quit();
  console.log(`Cleared ${deleted} rate-limit key(s).`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
