import type { Request, Response } from "express";
import { z } from "zod";
import { AppError } from "../../middleware/error.middleware";
import { addVaultItemSchema } from "./vault.schema";
import { vaultService } from "./vault.service";

function requireUserId(req: Request): string {
  if (!req.user) {
    throw new AppError(401, "UNAUTHORIZED", "Missing access token");
  }

  return req.user.userId;
}

export class VaultController {
  async list(req: Request, res: Response): Promise<void> {
    res.status(200).json(await vaultService.list(requireUserId(req)));
  }

  async add(req: Request, res: Response): Promise<void> {
    const input = addVaultItemSchema.parse(req.body);
    res.status(201).json(await vaultService.add(requireUserId(req), input.product_id));
  }

  async remove(req: Request, res: Response): Promise<void> {
    const itemId = z.string().uuid().parse(req.params.itemId);
    res.status(200).json(await vaultService.remove(requireUserId(req), itemId));
  }

  async removeByProduct(req: Request, res: Response): Promise<void> {
    const productId = z.string().uuid().parse(req.params.productId);
    res
      .status(200)
      .json(await vaultService.removeByProductId(requireUserId(req), productId));
  }
}

export const vaultController = new VaultController();
