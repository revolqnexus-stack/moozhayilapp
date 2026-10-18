import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import {
  buildAffordability,
  buildGoalSuggestion,
  mapProductToDto,
  productInclude,
} from "../products/product.mapper";

export class VaultService {
  async list(userId: string) {
    const items = await prisma.dreamVaultItem.findMany({
      where: { userId, removedAt: null },
      include: {
        product: { include: productInclude() },
      },
      orderBy: { addedAt: "desc" },
    });

    const mapped = await Promise.all(
      items.map(async (item) => {
        const productDto = await mapProductToDto(item.product, {
          vaultProductIds: new Set([item.productId]),
        });

        return {
          id: item.id,
          product: productDto,
          goal: null,
          affordability: buildAffordability(
            item.product,
            productDto.price.total_paise,
          ),
          added_at: item.addedAt.toISOString(),
        };
      }),
    );

    return { items: mapped, count: mapped.length };
  }

  async add(userId: string, productId: string) {
    const product = await prisma.product.findFirst({
      where: { id: productId, isPublished: true, deletedAt: null },
      include: productInclude(),
    });

    if (!product) {
      throw new AppError(404, "NOT_FOUND", "Product does not exist");
    }

    const existingActive = await prisma.dreamVaultItem.findFirst({
      where: { userId, productId, removedAt: null },
    });

    if (existingActive) {
      throw new AppError(409, "CONFLICT", "Product is already in Dream Vault");
    }

    const restored = await prisma.dreamVaultItem.findFirst({
      where: { userId, productId, removedAt: { not: null } },
      orderBy: { removedAt: "desc" },
    });

    const vaultItem = restored
      ? await prisma.dreamVaultItem.update({
          where: { id: restored.id },
          data: { removedAt: null, addedAt: new Date() },
          include: { product: { include: productInclude() } },
        })
      : await prisma.dreamVaultItem.create({
          data: { userId, productId },
          include: { product: { include: productInclude() } },
        });

    const productDto = await mapProductToDto(vaultItem.product, {
      vaultProductIds: new Set([productId]),
    });

    return {
      vault_item: {
        id: vaultItem.id,
        product: productDto,
        goal: null,
        affordability: buildAffordability(
          vaultItem.product,
          productDto.price.total_paise,
        ),
        added_at: vaultItem.addedAt.toISOString(),
      },
      goal_suggestion: buildGoalSuggestion(productDto.price.total_paise),
    };
  }

  async remove(userId: string, itemId: string) {
    const item = await prisma.dreamVaultItem.findFirst({
      where: { id: itemId, userId, removedAt: null },
    });

    if (!item) {
      return { success: true };
    }

    await prisma.dreamVaultItem.update({
      where: { id: item.id },
      data: { removedAt: new Date() },
    });

    return { success: true };
  }

  async removeByProductId(userId: string, productId: string) {
    const item = await prisma.dreamVaultItem.findFirst({
      where: { userId, productId, removedAt: null },
      orderBy: { addedAt: "desc" },
    });

    if (!item) {
      return { success: true };
    }

    await prisma.dreamVaultItem.update({
      where: { id: item.id },
      data: { removedAt: new Date() },
    });

    return { success: true };
  }

  async vaultProductIds(userId: string): Promise<Set<string>> {
    const items = await prisma.dreamVaultItem.findMany({
      where: { userId, removedAt: null },
      select: { productId: true },
    });

    return new Set(items.map((item) => item.productId));
  }
}

export const vaultService = new VaultService();
