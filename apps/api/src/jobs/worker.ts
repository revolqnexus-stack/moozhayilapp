import dotenv from "dotenv";

dotenv.config({
  path: process.env.MOOZHAYIL_ENV_FILE ?? ".env",
});
import http from "http";
import { validateEnvironment } from "../app";
import { logger } from "../utils/logger";
import { initMonitoring } from "../utils/monitoring";
import {
  scheduleRepeatableNotificationJobs,
  scheduleRepeatableOperationsJobs,
  startWorkers,
} from "./queues";
import { loadEnv } from "../config/env";

async function main() {
  validateEnvironment();
  initMonitoring();

  const env = loadEnv();
  const workers = startWorkers();
  if (workers.length === 0) {
    logger.error("[worker] Redis unavailable; workers not started");
    process.exit(1);
  }

  await scheduleRepeatableNotificationJobs();
  await scheduleRepeatableOperationsJobs();

  const server = http.createServer((_req, res) => {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        status: "ok",
        workers: workers.length,
        timestamp: new Date().toISOString(),
      }),
    );
  });

  server.listen(env.WORKER_HEALTH_PORT, () => {
    logger.info("[worker] health endpoint listening", {
      port: env.WORKER_HEALTH_PORT,
      workers: workers.length,
    });
  });

  logger.info("[worker] started BullMQ workers", { count: workers.length });
}

void main();
