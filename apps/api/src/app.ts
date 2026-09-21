import express, { type Express } from "express";
import helmet from "helmet";
import path from "path";
import { loadEnv } from "./config/env";
import { getHealthReport } from "./modules/health/health.service";
import {
  errorMiddleware,
  notFoundHandler,
} from "./middleware/error.middleware";
import { requestIdMiddleware } from "./middleware/request_id.middleware";
import { requestLoggerMiddleware } from "./middleware/request_logger.middleware";
import { corsMiddleware } from "./middleware/cors.middleware";
import {
  publicIpRateLimit,
} from "./middleware/rate_limit.middleware";
import { webhooksRouter } from "./modules/webhooks/webhooks.routes";
import { addressesRouter } from "./modules/addresses/addresses.routes";
import { adminRouter } from "./modules/admin/admin.routes";
import { authRouter } from "./modules/auth/auth.routes";
import { cartRouter } from "./modules/cart/cart.routes";
import { catalogRouter } from "./modules/catalog/catalog.routes";
import { cmsRouter } from "./modules/cms/cms.routes";
import { contributionsRouter } from "./modules/contributions/contributions.routes";
import { goalsRouter } from "./modules/goals/goals.routes";
import { goldRatesRouter } from "./modules/gold_rates/gold_rates.routes";
import { goldBalanceRouter } from "./modules/gold_ledger/gold_ledger.routes";
import { kycRouter } from "./modules/kyc/kyc.routes";
import { productsRouter } from "./modules/products/products.routes";
import { plansRouter } from "./modules/plans/plans.routes";
import { paymentsRouter } from "./modules/payments/payments.routes";
import { ordersRouter } from "./modules/orders/orders.routes";
import { quotesRouter } from "./modules/quotes/quote.routes";
import { notificationsRouter } from "./modules/notifications/notifications.routes";
import { auraRouter } from "./modules/aura/aura.routes";
import { referralsRouter } from "./modules/referrals/referrals.routes";
import { storesRouter } from "./modules/stores/stores.routes";
import { usersRouter } from "./modules/users/users.routes";
import { vaultRouter } from "./modules/vault/vault.routes";
import { initMonitoring } from "./utils/monitoring";

export interface CreateAppOptions {
  beforeNotFound?: (app: Express) => void;
}

export function createApp(options: CreateAppOptions = {}) {
  const env = loadEnv();
  initMonitoring();

  const app = express();

  if (env.TRUST_PROXY) {
    app.set("trust proxy", 1);
  }

  app.disable("x-powered-by");
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: "cross-origin" },
      contentSecurityPolicy: env.NODE_ENV === "production" ? undefined : false,
    }),
  );
  app.use(corsMiddleware);
  app.use(requestIdMiddleware);
  app.use(requestLoggerMiddleware);
  app.use(publicIpRateLimit);

  app.use(
    "/v1/webhooks",
    express.raw({ type: "application/json", limit: "1mb" }),
    webhooksRouter,
  );

  app.use(express.json({ limit: "1mb" }));

  if (env.STORAGE_BACKEND === "local") {
    app.use(
      "/uploads/media",
      express.static(path.resolve(env.MEDIA_UPLOAD_DIR)),
    );
  }

  const healthHandler = async (
    _req: express.Request,
    res: express.Response,
  ): Promise<void> => {
    const report = await getHealthReport();
    const statusCode = report.status === "error" ? 503 : 200;
    res.status(statusCode).json(report);
  };

  app.get("/health", (req, res, next) => {
    void healthHandler(req, res).catch(next);
  });

  app.get("/v1/health", (req, res, next) => {
    void healthHandler(req, res).catch(next);
  });

  app.use("/v1/auth", authRouter);
  app.use("/v1/user", usersRouter);
  app.use("/v1/kyc", kycRouter);
  app.use("/v1/admin", adminRouter);
  app.use("/v1", catalogRouter);
  app.use("/v1", cmsRouter);
  app.use("/v1/gold-rate", goldRatesRouter);
  app.use("/v1/products", productsRouter);
  app.use("/v1/vault", vaultRouter);
  app.use("/v1/cart", cartRouter);
  app.use("/v1/quotes", quotesRouter);
  app.use("/v1/addresses", addressesRouter);
  app.use("/v1/goals", goalsRouter);
  app.use("/v1/contributions", contributionsRouter);
  app.use("/v1/gold-balance", goldBalanceRouter);
  app.use("/v1/payments", paymentsRouter);
  app.use("/v1/orders", ordersRouter);
  app.use("/v1/notifications", notificationsRouter);
  app.use("/v1/aura", auraRouter);
  app.use("/v1/referrals", referralsRouter);
  app.use("/v1/stores", storesRouter);
  app.use("/v1/plans", plansRouter);

  options.beforeNotFound?.(app);

  app.use(notFoundHandler);
  app.use(errorMiddleware);

  return app;
}

export function validateEnvironment() {
  return loadEnv();
}
