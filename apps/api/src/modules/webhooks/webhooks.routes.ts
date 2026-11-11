import { Router } from "express";
import { webhooksController } from "./webhooks.controller";

export const webhooksRouter = Router();

webhooksRouter.post("/payment", (req, res, next) => {
  void webhooksController.payment(req, res).catch(next);
});

webhooksRouter.post("/kyc", (req, res, next) => {
  void webhooksController.kyc(req, res).catch(next);
});

webhooksRouter.post("/gold-rate", (req, res, next) => {
  void webhooksController.goldRate(req, res).catch(next);
});

webhooksRouter.post("/stampmitra", (req, res, next) => {
  void webhooksController.stampmitra(req, res).catch(next);
});
