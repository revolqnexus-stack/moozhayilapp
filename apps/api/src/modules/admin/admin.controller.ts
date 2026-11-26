import type { Request, Response } from "express";
import { z } from "zod";
import { AppError } from "../../middleware/error.middleware";
import { getRequestId } from "../../middleware/request_id.middleware";
import {
  adminBannerCreateSchema,
  adminBannerUpdateSchema,
  adminCatalogCreateSchema,
  adminCatalogUpdateSchema,
  adminLoginSchema,
  adminOrderListSchema,
  adminOrderRefundSchema,
  adminOrderStatusSchema,
  adminProductCreateSchema,
  adminProductImageSchema,
  adminProductListSchema,
  adminProductUpdateSchema,
  adminStepUpSchema,
  adminUserListSchema,
  adminUserCreateSchema,
  adminGoalCreateSchema,
  adminShowroomPaymentSchema,
  auditLogQuerySchema,
  goldRateOverrideSchema,
  inventoryStockUpdateSchema,
  ledgerAdjustmentCreateSchema,
  rejectKycSchema,
  sarReviewDecisionSchema,
} from "./admin.schema";
import { adminService } from "./admin.service";
import { adminAuthService } from "./admin_auth.service";
import { auditService } from "./audit.service";
import { ordersAdminService } from "./orders.admin.service";
import { productsAdminService } from "./products.admin.service";
import { catalogAdminService } from "./catalog.admin.service";
import { cmsAdminService } from "./cms.admin.service";
import { goldRateOverrideService } from "./gold_rate_override.service";
import {
  ledgerAdjustmentsService,
  sarReviewsService,
  usersAdminService,
} from "./users.admin.service";
import { analyticsAdminService } from "./analytics.admin.service";
import { inventoryAdminService } from "./inventory.admin.service";
import { notificationsAdminService } from "./notifications.admin.service";
import { plansService } from "../plans/plans.service";
import { adminPlanInterestListSchema } from "../plans/plans.schema";
import { schemesAdminService } from "./schemes.admin.service";
import {
  saveAdminMediaUpload,
} from "./uploads.admin.service";
import { opsAdminService } from "./ops.admin.service";
import {
  adminPincodeCreateSchema,
  adminPincodeImportSchema,
  adminStoreCreateSchema,
  adminStoreUpdateSchema,
} from "./ops.admin.schema";

function requireAdminId(req: Request): string {
  if (!req.admin) {
    throw new AppError(401, "UNAUTHORIZED", "Missing admin access token");
  }

  return req.admin.adminId;
}

function requireIdempotencyKey(req: Request): string {
  const key = req.header("idempotency-key");
  if (!key) {
    throw new AppError(400, "BAD_REQUEST", "Idempotency-Key header is required");
  }
  return key;
}

export class AdminController {
  async login(req: Request, res: Response): Promise<void> {
    const input = adminLoginSchema.parse(req.body);
    res.status(200).json(await adminAuthService.login(input));
  }

  async stepUp(req: Request, res: Response): Promise<void> {
    const input = adminStepUpSchema.parse(req.body);
    res.status(200).json(
      await adminAuthService.stepUp(requireAdminId(req), input.password),
    );
  }

  async me(req: Request, res: Response): Promise<void> {
    res.status(200).json(await adminAuthService.me(requireAdminId(req)));
  }

  async dashboard(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await analyticsAdminService.dashboard());
  }

  async listAuditLogs(req: Request, res: Response): Promise<void> {
    const input = auditLogQuerySchema.parse(req.query);
    res.status(200).json(await auditService.list(input));
  }

  async listKycReviews(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await adminService.listKycReviews());
  }

  async getKycSelfie(req: Request, res: Response): Promise<void> {
    const userId = z.string().uuid().parse(req.params.userId);
    const { stream, contentType } = await adminService.getKycSelfieStream(userId);
    res.setHeader("Content-Type", contentType);
    stream.pipe(res);
  }

  async uploadMedia(req: Request, res: Response): Promise<void> {
    if (!req.file) {
      throw new AppError(400, "BAD_REQUEST", "Image file is required");
    }

    const folder = z.enum(["banners", "products"]).parse(
      typeof req.query.folder === "string" ? req.query.folder : "products",
    );
    const stored = await saveAdminMediaUpload(req.file, folder);
    res.status(201).json({
      url: stored.publicUrl,
      path: stored.fileName,
    });
  }

  async approveKyc(req: Request, res: Response): Promise<void> {
    const userId = z.string().uuid().parse(req.params.userId);
    res.status(200).json(
      await adminService.approveKyc(
        userId,
        requireAdminId(req),
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async rejectKyc(req: Request, res: Response): Promise<void> {
    const userId = z.string().uuid().parse(req.params.userId);
    const input = rejectKycSchema.parse(req.body);
    res.status(200).json(
      await adminService.rejectKyc(
        userId,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listOrders(req: Request, res: Response): Promise<void> {
    const input = adminOrderListSchema.parse(req.query);
    res.status(200).json(await ordersAdminService.list(input));
  }

  async getOrder(req: Request, res: Response): Promise<void> {
    const orderId = z.string().uuid().parse(req.params.id);
    res.status(200).json(await ordersAdminService.getById(orderId));
  }

  async updateOrderStatus(req: Request, res: Response): Promise<void> {
    const orderId = z.string().uuid().parse(req.params.id);
    const input = adminOrderStatusSchema.parse(req.body);
    res.status(200).json(
      await ordersAdminService.updateStatus(
        orderId,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async refundOrder(req: Request, res: Response): Promise<void> {
    const orderId = z.string().uuid().parse(req.params.id);
    const input = adminOrderRefundSchema.parse(req.body);
    res.status(200).json(
      await ordersAdminService.refund(
        orderId,
        requireAdminId(req),
        input,
        requireIdempotencyKey(req),
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listSarReviews(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await ordersAdminService.listSarReviews());
  }

  async decideSarReview(req: Request, res: Response): Promise<void> {
    const reviewId = z.string().uuid().parse(req.params.id);
    const input = sarReviewDecisionSchema.parse(req.body);
    res.status(200).json(
      await sarReviewsService.decide(
        reviewId,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async overrideGoldRate(req: Request, res: Response): Promise<void> {
    const input = goldRateOverrideSchema.parse(req.body);
    res.status(200).json(
      await goldRateOverrideService.override(
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listGoldRateHistory(req: Request, res: Response): Promise<void> {
    const purity =
      typeof req.query.purity === "string" ? req.query.purity : undefined;
    res.status(200).json(await goldRateOverrideService.listHistory(purity));
  }

  async listProducts(req: Request, res: Response): Promise<void> {
    const input = adminProductListSchema.parse(req.query);
    res.status(200).json(await productsAdminService.list(input));
  }

  async getProduct(req: Request, res: Response): Promise<void> {
    const productId = z.string().uuid().parse(req.params.id);
    res.status(200).json(await productsAdminService.get(productId));
  }

  async createProduct(req: Request, res: Response): Promise<void> {
    const input = adminProductCreateSchema.parse(req.body);
    res.status(201).json(
      await productsAdminService.create(
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async updateProduct(req: Request, res: Response): Promise<void> {
    const productId = z.string().uuid().parse(req.params.id);
    const input = adminProductUpdateSchema.parse(req.body);
    res.status(200).json(
      await productsAdminService.update(
        productId,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async addProductImage(req: Request, res: Response): Promise<void> {
    const productId = z.string().uuid().parse(req.params.id);
    const input = adminProductImageSchema.parse(req.body);
    res.status(201).json(
      await productsAdminService.addImage(
        productId,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async publishProduct(req: Request, res: Response): Promise<void> {
    const productId = z.string().uuid().parse(req.params.id);
    res.status(200).json(
      await productsAdminService.publish(
        productId,
        requireAdminId(req),
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listCategories(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await catalogAdminService.listCategories());
  }

  async createCategory(req: Request, res: Response): Promise<void> {
    const input = adminCatalogCreateSchema.parse(req.body);
    res.status(201).json(
      await catalogAdminService.createCategory(
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async updateCategory(req: Request, res: Response): Promise<void> {
    const id = z.string().uuid().parse(req.params.id);
    const input = adminCatalogUpdateSchema.parse(req.body);
    res.status(200).json(
      await catalogAdminService.updateCategory(
        id,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listCollections(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await catalogAdminService.listCollections());
  }

  async createCollection(req: Request, res: Response): Promise<void> {
    const input = adminCatalogCreateSchema.parse(req.body);
    res.status(201).json(
      await catalogAdminService.createCollection(
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async updateCollection(req: Request, res: Response): Promise<void> {
    const id = z.string().uuid().parse(req.params.id);
    const input = adminCatalogUpdateSchema.parse(req.body);
    res.status(200).json(
      await catalogAdminService.updateCollection(
        id,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listOccasions(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await catalogAdminService.listOccasions());
  }

  async createOccasion(req: Request, res: Response): Promise<void> {
    const input = adminCatalogCreateSchema.parse(req.body);
    res.status(201).json(
      await catalogAdminService.createOccasion(
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async updateOccasion(req: Request, res: Response): Promise<void> {
    const id = z.string().uuid().parse(req.params.id);
    const input = adminCatalogUpdateSchema.parse(req.body);
    res.status(200).json(
      await catalogAdminService.updateOccasion(
        id,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listBanners(req: Request, res: Response): Promise<void> {
    const placement =
      typeof req.query.placement === "string" ? req.query.placement : undefined;
    res.status(200).json(await cmsAdminService.listBanners(placement));
  }

  async createBanner(req: Request, res: Response): Promise<void> {
    const input = adminBannerCreateSchema.parse(req.body);
    res.status(201).json(
      await cmsAdminService.createBanner(
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async updateBanner(req: Request, res: Response): Promise<void> {
    const bannerId = z.string().uuid().parse(req.params.id);
    const input = adminBannerUpdateSchema.parse(req.body);
    res.status(200).json(
      await cmsAdminService.updateBanner(
        bannerId,
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listHomeContent(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await cmsAdminService.listHomeContent());
  }

  async listFeaturedProducts(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await cmsAdminService.listFeaturedProducts());
  }

  async listUsers(req: Request, res: Response): Promise<void> {
    const input = adminUserListSchema.parse(req.query);
    res.status(200).json(await usersAdminService.listUsers(input));
  }

  async getCustomer(req: Request, res: Response): Promise<void> {
    const userId = z.string().uuid().parse(req.params.id);
    res.status(200).json(await usersAdminService.getCustomerDetail(userId));
  }

  async createCustomer(req: Request, res: Response): Promise<void> {
    const input = adminUserCreateSchema.parse(req.body);
    res.status(201).json(
      await usersAdminService.createCustomer(
        requireAdminId(req),
        input,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async supportSummary(req: Request, res: Response): Promise<void> {
    const userId = z.string().uuid().parse(req.params.id);
    res.status(200).json(await usersAdminService.supportSummary(userId));
  }

  async listLedgerAdjustments(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await ledgerAdjustmentsService.list());
  }

  async createLedgerAdjustment(req: Request, res: Response): Promise<void> {
    const input = ledgerAdjustmentCreateSchema.parse(req.body);
    res.status(201).json(
      await ledgerAdjustmentsService.create(
        requireAdminId(req),
        input,
        requireIdempotencyKey(req),
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async approveLedgerAdjustment(req: Request, res: Response): Promise<void> {
    const adjustmentId = z.string().uuid().parse(req.params.id);
    res.status(200).json(
      await ledgerAdjustmentsService.approve(
        adjustmentId,
        requireAdminId(req),
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listInventory(req: Request, res: Response): Promise<void> {
    const lowStockOnly = req.query.low_stock_only === "true";
    const cursor =
      typeof req.query.cursor === "string" ? req.query.cursor : undefined;
    const limit = z.coerce.number().int().min(1).max(100).default(25).parse(
      req.query.limit ?? 25,
    );
    res.status(200).json(
      await inventoryAdminService.listStock({
        low_stock_only: lowStockOnly,
        cursor,
        limit,
      }),
    );
  }

  async updateInventory(req: Request, res: Response): Promise<void> {
    const productId = z.string().uuid().parse(req.params.id);
    const input = inventoryStockUpdateSchema.parse(req.body);
    res.status(200).json(
      await inventoryAdminService.updateStock(
        productId,
        requireAdminId(req),
        input.stock_quantity,
        input.reason,
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listInventoryReservations(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await inventoryAdminService.listReservations());
  }

  async listNotifications(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await notificationsAdminService.listRecent());
  }

  async listPlanInterests(req: Request, res: Response): Promise<void> {
    const query = adminPlanInterestListSchema.parse(req.query);
    res.status(200).json(
      await plansService.listInterestsAdmin({
        schemeType: query.scheme_type,
        limit: query.limit,
        cursor: query.cursor,
      }),
    );
  }

  async enrollCustomerGoal(req: Request, res: Response): Promise<void> {
    const userId = z.string().uuid().parse(req.params.userId);
    const input = adminGoalCreateSchema.parse(req.body);
    res.status(201).json(
      await schemesAdminService.enrollCustomer(
        userId,
        requireAdminId(req),
        input,
        requireIdempotencyKey(req),
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async getAdminGoal(req: Request, res: Response): Promise<void> {
    const goalId = z.string().uuid().parse(req.params.goalId);
    res.status(200).json(await schemesAdminService.getGoal(goalId));
  }

  async listGoalContributions(req: Request, res: Response): Promise<void> {
    const goalId = z.string().uuid().parse(req.params.goalId);
    res.status(200).json(
      await schemesAdminService.listGoalContributions(goalId),
    );
  }

  async recordShowroomPayment(req: Request, res: Response): Promise<void> {
    const goalId = z.string().uuid().parse(req.params.goalId);
    const input = adminShowroomPaymentSchema.parse(req.body);
    res.status(201).json(
      await schemesAdminService.recordShowroomPayment(
        goalId,
        requireAdminId(req),
        input,
        requireIdempotencyKey(req),
        getRequestId(req),
        req.ip,
      ),
    );
  }

  async listServiceablePincodes(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await opsAdminService.listServiceablePincodes());
  }

  async createServiceablePincode(req: Request, res: Response): Promise<void> {
    const input = adminPincodeCreateSchema.parse(req.body);
    res.status(201).json(await opsAdminService.createServiceablePincode(input));
  }

  async importServiceablePincodes(req: Request, res: Response): Promise<void> {
    const input = adminPincodeImportSchema.parse(req.body);
    res.status(200).json(await opsAdminService.importServiceablePincodes(input));
  }

  async deleteServiceablePincode(req: Request, res: Response): Promise<void> {
    const id = z.string().uuid().parse(req.params.id);
    res.status(200).json(await opsAdminService.deleteServiceablePincode(id));
  }

  async listStoreLocations(_req: Request, res: Response): Promise<void> {
    res.status(200).json(await opsAdminService.listStoreLocations());
  }

  async createStoreLocation(req: Request, res: Response): Promise<void> {
    const input = adminStoreCreateSchema.parse(req.body);
    res.status(201).json(await opsAdminService.createStoreLocation(input));
  }

  async updateStoreLocation(req: Request, res: Response): Promise<void> {
    const id = z.string().uuid().parse(req.params.id);
    const input = adminStoreUpdateSchema.parse(req.body);
    res.status(200).json(await opsAdminService.updateStoreLocation(id, input));
  }
}

export const adminController = new AdminController();
