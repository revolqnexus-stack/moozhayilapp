import { prisma } from "../../db/prisma";
import { loadEnv } from "../../config/env";
import Redis from "ioredis";

export type HealthStatus = "ok" | "degraded" | "error";

export interface HealthReport {
  status: HealthStatus;
  timestamp: string;
  checks: {
    database: { status: HealthStatus; latency_ms?: number; error?: string };
    redis: { status: HealthStatus; latency_ms?: number; error?: string };
  };
}

export async function getHealthReport(): Promise<HealthReport> {
  const timestamp = new Date().toISOString();
  const [database, redis] = await Promise.all([
    checkDatabase(),
    checkRedis(),
  ]);

  const statuses = [database.status, redis.status];
  const status: HealthStatus = statuses.every((value) => value === "ok")
    ? "ok"
    : statuses.some((value) => value === "error")
      ? "error"
      : "degraded";

  return {
    status,
    timestamp,
    checks: { database, redis },
  };
}

async function checkDatabase(): Promise<HealthReport["checks"]["database"]> {
  const started = Date.now();
  try {
    await prisma.$queryRaw`SELECT 1`;
    return { status: "ok", latency_ms: Date.now() - started };
  } catch (error) {
    return {
      status: "error",
      latency_ms: Date.now() - started,
      error: error instanceof Error ? error.message : "Database unavailable",
    };
  }
}

async function checkRedis(): Promise<HealthReport["checks"]["redis"]> {
  const started = Date.now();
  let client: Redis | null = null;
  try {
    const env = loadEnv();
    client = new Redis(env.REDIS_URL, {
      maxRetriesPerRequest: 1,
      connectTimeout: 2000,
      lazyConnect: true,
    });
    console.log(`[health] Redis status before connect: ${client.status}`);
    await client.connect();
    console.log(`[health] Redis status after connect: ${client.status}`);
    const pong = await client.ping();
    if (pong !== "PONG") {
      throw new Error("Unexpected Redis response");
    }
    return { status: "ok", latency_ms: Date.now() - started };
  } catch (error) {
    console.error('[health] Redis check failed:', error);
    return {
      status: "error",
      latency_ms: Date.now() - started,
      error: error instanceof Error ? error.message : "Redis unavailable",
    };
  } finally {
    if (client) {
      console.log(`[health] Disconnecting Redis client, status: ${client.status}`);
      client.disconnect();
    }
  }
}
