import { prisma } from "../../db/prisma";
import { getJsonCache } from "../../utils/cache";

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
  try {
    // Use a lightweight cache operation to test Redis
    // getJsonCache handles connection internally and degrades gracefully
    await getJsonCache("health:ping");
    return { status: "ok", latency_ms: Date.now() - started };
  } catch (error) {
    return {
      status: "error",
      latency_ms: Date.now() - started,
      error: error instanceof Error ? error.message : "Redis unavailable",
    };
  }
}
