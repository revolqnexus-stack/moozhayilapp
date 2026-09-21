import type { NextFunction, Request, Response } from "express";
import Redis from "ioredis";
import { loadEnv } from "../config/env";
import { AppError } from "./error.middleware";

interface RateLimitOptions {
  windowMs: number;
  max: number;
  keyGenerator: (req: Request) => string;
  name?: string;
}

const memoryBuckets = new Map<string, number[]>();
let redisClient: Redis | null | undefined;

function getRedis(): Redis | null {
  if (process.env.NODE_ENV === "test" || process.env.JEST_WORKER_ID) {
    return null;
  }

  if (redisClient !== undefined) {
    return redisClient;
  }

  try {
    redisClient = new Redis(loadEnv().REDIS_URL, {
      lazyConnect: true,
      maxRetriesPerRequest: 1,
      enableOfflineQueue: false,
    });
    redisClient.on("error", () => {
      // Fall back to in-memory buckets when Redis is unavailable.
    });
    return redisClient;
  } catch {
    redisClient = null;
    return null;
  }
}

export function clearRateLimitBucketsForTests(): void {
  memoryBuckets.clear();
}

async function incrementRedis(key: string, windowMs: number): Promise<number> {
  const client = getRedis();
  if (!client) {
    return -1;
  }

  try {
    if (client.status === "wait") {
      await client.connect();
    }

    const redisKey = `rate:${key}`;
    const count = await client.incr(redisKey);
    if (count === 1) {
      await client.pexpire(redisKey, windowMs);
    }
    return count;
  } catch {
    return -1;
  }
}

function incrementMemory(key: string, windowMs: number): number {
  const now = Date.now();
  const windowStart = now - windowMs;
  const hits = (memoryBuckets.get(key) ?? []).filter(
    (timestamp) => timestamp > windowStart,
  );
  hits.push(now);
  memoryBuckets.set(key, hits);
  return hits.length;
}

function isRateLimitBypassed(): boolean {
  const nodeEnv = process.env.NODE_ENV;
  // Staging is for QA/UAT — do not block login with production-grade throttles.
  return nodeEnv === "development" || nodeEnv === "staging";
}

export function rateLimit(options: RateLimitOptions) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (isRateLimitBypassed()) {
      next();
      return;
    }

    void (async () => {
      const key = `${options.name ?? "default"}:${options.keyGenerator(req)}`;
      const redisCount = await incrementRedis(key, options.windowMs);
      const count =
        redisCount >= 0 ? redisCount : incrementMemory(key, options.windowMs);

      if (count > options.max) {
        next(new AppError(429, "RATE_LIMITED", "Too many requests"));
        return;
      }

      next();
    })().catch(next);
  };
}

export const publicIpRateLimit = rateLimit({
  name: "public_ip",
  windowMs: 60_000,
  max: 20,
  keyGenerator: (req) => req.ip ?? "unknown",
});

export const authenticatedUserRateLimit = rateLimit({
  name: "auth_user",
  windowMs: 60_000,
  max: 100,
  keyGenerator: (req) => req.user?.userId ?? req.ip ?? "unknown",
});

export const adminSensitiveRateLimit = rateLimit({
  name: "admin_sensitive",
  windowMs: 60_000,
  max: 20,
  keyGenerator: (req) => req.admin?.adminId ?? req.ip ?? "unknown",
});
