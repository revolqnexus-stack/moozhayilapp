import Redis from "ioredis";
import { loadEnv } from "../config/env";

let redis: Redis | null | undefined;

function client(): Redis | null {
  if (process.env.NODE_ENV === "test" || process.env.JEST_WORKER_ID) {
    return null;
  }

  if (redis !== undefined) {
    return redis;
  }

  try {
    redis = new Redis(loadEnv().REDIS_URL, {
      lazyConnect: true,
      maxRetriesPerRequest: null,
      enableOfflineQueue: false,
      retryStrategy: (times) => {
        // Retry indefinitely with exponential backoff (max 3 seconds)
        return Math.min(times * 200, 3000);
      },
      reconnectOnError: () => true,
    });
    redis.on("error", (err) => {
      // Redis is cache only. API handlers degrade to PostgreSQL on failure.
      console.error("Redis error:", err.message);
    });
    return redis;
  } catch {
    redis = null;
    return null;
  }
}

export async function getJsonCache<T>(key: string): Promise<T | null> {
  const redisClient = client();
  if (!redisClient) {
    return null;
  }

  try {
    if (redisClient.status === "wait") {
      await redisClient.connect();
    }
    const value = await redisClient.get(key);
    return value ? (JSON.parse(value) as T) : null;
  } catch {
    return null;
  }
}

export async function setJsonCache(
  key: string,
  value: unknown,
  ttlSeconds: number,
): Promise<void> {
  const redisClient = client();
  if (!redisClient) {
    return;
  }

  try {
    if (redisClient.status === "wait") {
      await redisClient.connect();
    }
    await redisClient.set(key, JSON.stringify(value), "EX", ttlSeconds);
  } catch {
    // Cache write failures must not affect correctness.
  }
}

export async function deleteCache(key: string): Promise<void> {
  const redisClient = client();
  if (!redisClient) {
    return;
  }

  try {
    if (redisClient.status === "wait") {
      await redisClient.connect();
    }
    await redisClient.del(key);
  } catch {
    // Cache delete failures must not affect correctness.
  }
}

export async function deleteCacheByPrefix(prefix: string): Promise<void> {
  const redisClient = client();
  if (!redisClient) {
    return;
  }

  try {
    if (redisClient.status === "wait") {
      await redisClient.connect();
    }

    let cursor = "0";
    do {
      const [nextCursor, keys] = await redisClient.scan(
        cursor,
        "MATCH",
        `${prefix}*`,
        "COUNT",
        100,
      );
      cursor = nextCursor;
      if (keys.length > 0) {
        await redisClient.del(...keys);
      }
    } while (cursor !== "0");
  } catch {
    // Cache delete failures must not affect correctness.
  }
}
