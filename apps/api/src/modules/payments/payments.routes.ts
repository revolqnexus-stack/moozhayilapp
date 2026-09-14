import { Router } from "express";
import { authenticate } from "../auth/auth.middleware";
import { authenticateAdmin, requireAdminRoles } from "../admin/admin.middleware";
import { paymentsController } from "./payments.controller";

export const paymentsRouter = Router();

paymentsRouter.post(
  "/reconcile",
  authenticateAdmin,
  requireAdminRoles("finance_manager", "super_admin"),
  (req, res, next) => {
    void paymentsController.reconcile(req, res).catch(next);
  },
);

paymentsRouter.use(authenticate);

paymentsRouter.post("/upi/verify", (req, res, next) => {
  void paymentsController.verifyUpi(req, res).catch(next);
});

paymentsRouter.get("/methods", (req, res, next) => {
  void paymentsController.listMethods(req, res).catch(next);
});

paymentsRouter.post("/methods", (req, res, next) => {
  void paymentsController.createMethod(req, res).catch(next);
});

paymentsRouter.delete("/methods/:id", (req, res, next) => {
  void paymentsController.deleteMethod(req, res).catch(next);
});

paymentsRouter.post("/capture-checkout", (req, res, next) => {
  void paymentsController.captureCheckout(req, res).catch(next);
});

paymentsRouter.post("/verify-razorpay", (req, res, next) => {
  void paymentsController.verifyRazorpaySignature(req, res).catch(next);
});
