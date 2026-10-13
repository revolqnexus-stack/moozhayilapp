import type { Prisma } from "@prisma/client";
import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import { logger } from "../../utils/logger";
import { dbPurity } from "../gold_rates/gold_rates.service";
import type {
  ProductListInput,
  ProductSearchInput,
  SimilarProductsInput,
} from "./products.schema";
import {
  mapProductToDto,
  productDetailQuery,
  productInclude,
  type ProductWithRelations,
} from "./product.mapper";

async function mapListedProducts(products: ProductWithRelations[]) {
  const priced = await Promise.all(
    products.map(async (product) => {
      try {
        return await mapProductToDto(product);
      } catch (error) {
        logger.warn("Skipping catalog product; live pricing unavailable", {
          product_id: product.id,
          sku: product.sku,
          purity: product.purity,
          error: error instanceof Error ? error.message : String(error),
        });
        return null;
      }
    }),
  );
  return priced.filter((product) => product !== null);
}

function sortImages(product: ProductWithRelations) {
  return [...product.images]
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .map((image) => ({
      id: image.id,
      url: image.cdnUrl,
      type: image.type,
      is_primary: image.isPrimary,
    }));
}

export class ProductsService {
  async list(input: ProductListInput) {
    const products = await prisma.product.findMany({
      where: this.whereForList(input),
      include: productInclude(),
      orderBy: this.orderBy(input.sort),
      cursor: input.cursor ? { id: input.cursor } : undefined,
      skip: input.cursor ? 1 : 0,
      take: input.limit + 1,
    });

    const priced = await mapListedProducts(products);
    const filtered = priced.filter((product) => {
      if (
        input.min_price_paise !== undefined &&
        product.price.total_paise < input.min_price_paise
      ) {
        return false;
      }
      if (
        input.max_price_paise !== undefined &&
        product.price.total_paise > input.max_price_paise
      ) {
        return false;
      }
      return true;
    });
    const sorted =
      input.sort === "price_asc" || input.sort === "price_desc"
        ? [...filtered].sort((a, b) =>
            input.sort === "price_asc"
              ? a.price.total_paise - b.price.total_paise
              : b.price.total_paise - a.price.total_paise,
          )
        : filtered;

    return {
      data: sorted.slice(0, input.limit),
      next_cursor: products.length > input.limit ? products[input.limit].id : null,
      has_more: products.length > input.limit,
    };
  }

  async detail(productId: string) {
    const product = await prisma.product.findFirst({
      where: {
        id: productId,
        isPublished: true,
        deletedAt: null,
      },
      ...productDetailQuery,
    });

    if (!product) {
      throw new AppError(404, "NOT_FOUND", "Product does not exist");
    }

    return {
      ...(await mapProductToDto(product)),
      images: sortImages(product),
      description: product.description,
      specs: {
        hallmark_number: product.hallmarkNumber,
        has_stones: product.hasStones,
        has_ar: product.hasAr,
      },
      occasions: product.occasionTags.map((tag) => ({
        id: tag.occasion.id,
        name: tag.occasion.name,
        slug: tag.occasion.slug,
      })),
    };
  }

  async similar(productId: string, input: SimilarProductsInput) {
    const product = await prisma.product.findFirst({
      where: { id: productId, isPublished: true, deletedAt: null },
      select: { categoryId: true, collectionId: true },
    });

    if (!product) {
      throw new AppError(404, "NOT_FOUND", "Product does not exist");
    }

    const products = await prisma.product.findMany({
      where: {
        id: { not: productId },
        isPublished: true,
        deletedAt: null,
        OR: [
          { categoryId: product.categoryId },
          ...(product.collectionId ? [{ collectionId: product.collectionId }] : []),
        ],
      },
      include: productInclude(),
      orderBy: [{ isFeatured: "desc" }, { createdAt: "desc" }],
      take: input.limit,
    });

    return mapListedProducts(products);
  }

  async search(input: ProductSearchInput) {
    const safeQuery = input.q.replace(/[^\p{L}\p{N}\s-]/gu, "").trim();
    const terms = safeQuery.split(/\s+/).filter(Boolean);
    const termFilters = terms.flatMap((term) => [
      { name: { contains: term, mode: "insensitive" as const } },
      { description: { contains: term, mode: "insensitive" as const } },
    ]);
    const [categories, collections, products] = await Promise.all([
      prisma.category.findMany({
        where: {
          isActive: true,
          OR: terms.map((term) => ({
            name: { contains: term, mode: "insensitive" },
          })),
        },
        take: input.limit,
        orderBy: { name: "asc" },
      }),
      prisma.collection.findMany({
        where: {
          isActive: true,
          OR: terms.map((term) => ({
            name: { contains: term, mode: "insensitive" },
          })),
        },
        take: input.limit,
        orderBy: { name: "asc" },
      }),
      prisma.product.findMany({
        where: {
          isPublished: true,
          deletedAt: null,
          OR: termFilters,
        },
        include: productInclude(),
        take: input.limit,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return {
      query: safeQuery,
      results: {
        categories: await Promise.all(
          categories.map(async (category) => ({
            id: category.id,
            name: category.name,
            product_count: await prisma.product.count({
              where: { categoryId: category.id, isPublished: true, deletedAt: null },
            }),
          })),
        ),
        collections: collections.map((collection) => ({
          id: collection.id,
          name: collection.name,
          cover_image: collection.coverImageUrl,
        })),
        products: await mapListedProducts(products),
      },
    };
  }

  private whereForList(input: ProductListInput): Prisma.ProductWhereInput {
    return {
      isPublished: true,
      deletedAt: null,
      ...(input.category_id ? { categoryId: input.category_id } : {}),
      ...(input.collection_id ? { collectionId: input.collection_id } : {}),
      ...(input.purity ? { purity: dbPurity(input.purity) } : {}),
      ...(input.is_featured !== undefined ? { isFeatured: input.is_featured } : {}),
      ...(input.search
        ? {
            OR: [
              { name: { contains: input.search, mode: "insensitive" } },
              { description: { contains: input.search, mode: "insensitive" } },
            ],
          }
        : {}),
      ...(input.occasion_id
        ? {
            occasionTags: {
              some: { occasionId: input.occasion_id },
            },
          }
        : {}),
    };
  }

  private orderBy(sort: ProductListInput["sort"]): Prisma.ProductOrderByWithRelationInput[] {
    switch (sort) {
      case "weight_asc":
        return [{ weightGrams: "asc" }, { createdAt: "desc" }];
      case "price_asc":
      case "price_desc":
      case "most_loved":
      case "newest":
      default:
        return [{ createdAt: "desc" }];
    }
  }
}

export const productsService = new ProductsService();
