import { Router } from "express";
import { authenticate } from "../auth/auth.middleware";
import { vaultController } from "./vault.controller";

export const vaultRouter = Router();

vaultRouter.use(authenticate);

vaultRouter.get("/", (req, res, next) => {
  void vaultController.list(req, res).catch(next);
});

vaultRouter.post("/", (req, res, next) => {
  void vaultController.add(req, res).catch(next);
});

vaultRouter.delete("/products/:productId", (req, res, next) => {
  void vaultController.removeByProduct(req, res).catch(next);
});

vaultRouter.delete("/:itemId", (req, res, next) => {
  void vaultController.remove(req, res).catch(next);
});
