import { Router } from "express";
import { authenticate } from "../auth/auth.middleware";
import { quoteController } from "./quote.controller";

export const quotesRouter = Router();

quotesRouter.use(authenticate);

quotesRouter.post("/", (req, res, next) => {
  void quoteController.create(req, res).catch(next);
});

quotesRouter.post("/from-cart", (req, res, next) => {
  void quoteController.createFromCart(req, res).catch(next);
});
