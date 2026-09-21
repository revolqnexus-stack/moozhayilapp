import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import { formatPaise } from "../../utils/money";
import { mapProductToDto, productInclude, type ProductWithRelations } from "../products/product.mapper";

export class CartService {
  async getCart(userId: string) {
    const items = await prisma.cartItem.findMany({
      where: { userId },
      include: { product: { include: productInclude() } },
      orderBy: { addedAt: "desc" },
    });

    return this.buildCartResponse(items);
  }

  async addItem(userId: string, productId: string, quantity: number) {
    const product = await prisma.product.findFirst({
      where: { id: productId, isPublished: true, deletedAt: null },
    });

    if (!product) {
      throw new AppError(404, "NOT_FOUND", "Product does not exist");
    }

    if (product.stockQuantity <= 0) {
      throw new AppError(400, "OUT_OF_STOCK", "Product is out of stock");
    }

    const existing = await prisma.cartItem.findUnique({
      where: { userId_productId: { userId, productId } },
    });

    if (existing) {
      throw new AppError(409, "CONFLICT", "Product is already in cart");
    }

    await prisma.cartItem.create({
      data: { userId, productId, quantity },
    });

    return this.getCart(userId);
  }

  async removeItem(userId: string, productId: string) {
    const item = await prisma.cartItem.findUnique({
      where: { userId_productId: { userId, productId } },
    });

    if (!item) {
      throw new AppError(404, "NOT_FOUND", "Cart item does not exist");
    }

    await prisma.cartItem.delete({ where: { id: item.id } });

    return this.getCart(userId);
  }

  async clear(userId: string) {
    await prisma.cartItem.deleteMany({ where: { userId } });
    return { success: true };
  }

  private async buildCartResponse(
    items: Array<{
      id: string;
      quantity: number;
      product: ProductWithRelations;
    }>,
  ) {
    const mappedItems = await Promise.all(
      items.map(async (item) => {
        const product = await mapProductToDto(item.product);
        return {
          id: item.id,
          product,
          quantity: item.quantity,
          is_available: product.stock_available,
          unavailable_reason: product.stock_available ? null : "Out of stock",
        };
      }),
    );

    const subtotalPaise = mappedItems.reduce(
      (sum, item) =>
        item.is_available
          ? sum + item.product.price.total_paise * item.quantity
          : sum,
      0,
    );

    const priceValidUntil = mappedItems.reduce<string | null>((latest, item) => {
      const validUntil = item.product.price.price_valid_until;
      if (!latest || validUntil > latest) {
        return validUntil;
      }
      return latest;
    }, null);

    return {
      items: mappedItems,
      subtotal_paise: subtotalPaise,
      subtotal_display: formatPaise(subtotalPaise),
      /** Gross order total for KYC gate — sum of product.price.total_paise (incl. GST). */
      kyc_gross_total_paise: subtotalPaise,
      item_count: mappedItems.reduce((sum, item) => sum + item.quantity, 0),
      price_valid_until: priceValidUntil,
    };
  }
}

export const cartService = new CartService();
