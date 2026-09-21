import type { Prisma } from "@prisma/client";
import { Prisma as PrismaClient } from "@prisma/client";
import { decimalString, formatGoldGrams } from "../../utils/gold";
import { formatPaise } from "../../utils/money";
import { apiPurity, goldRatesService } from "../gold_rates/gold_rates.service";
import { calculateProductPrice } from "./price";

export const productDetailQuery = PrismaClient.validator<Prisma.ProductDefaultArgs>()({
  include: {
    category: true,
    collection: true,
    images: { orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }] },
    occasionTags: { include: { occasion: true } },
  },
});

export type ProductWithRelations = Prisma.ProductGetPayload<{
  include: {
    category: true;
    collection: true;
    images: true;
  };
}>;

export type ProductDetailRelations = Prisma.ProductGetPayload<typeof productDetailQuery>;

export function productInclude(): Prisma.ProductInclude {
  return {
    category: true,
    collection: true,
    images: { orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }] },
  };
}

export function productDetailInclude(): Prisma.ProductInclude {
  return productDetailQuery.include;
}

function primaryImage(product: ProductWithRelations): string | null {
  const primary =
    product.images.find((image) => image.isPrimary) ?? product.images[0];
  return primary?.cdnUrl ?? null;
}

export async function mapProductToDto(
  product: ProductWithRelations,
  options: { vaultProductIds?: Set<string> } = {},
) {
  const currentRate = await goldRatesService.currentRateForPurity(product.purity);
  const serverTime = new Date();
  const price = {
    ...calculateProductPrice({
      weightGrams: product.weightGrams,
      ratePerGramPaise: currentRate.ratePerGramPaise,
      makingChargePct: product.makingChargePct,
      wastagePct: product.wastagePct,
      stoneValuePaise: product.stoneValuePaise,
      gstPct: product.gstPct,
      rateUpdatedAt: currentRate.effectiveFrom,
      generatedAt: serverTime,
    }),
    server_time: serverTime.toISOString(),
  };
  const schemeMonthlyPaise = Math.ceil(price.total_paise / 36 / 100) * 100;

  return {
    id: product.id,
    sku: product.sku,
    name: product.name,
    category: {
      id: product.category.id,
      name: product.category.name,
      slug: product.category.slug,
    },
    collection: product.collection
      ? {
          id: product.collection.id,
          name: product.collection.name,
          slug: product.collection.slug,
        }
      : null,
    purity: apiPurity(product.purity),
    purity_display: apiPurity(product.purity).toUpperCase(),
    weight_grams: decimalString(product.weightGrams),
    weight_display: formatGoldGrams(product.weightGrams),
    price,
    scheme_monthly: {
      amount_paise: schemeMonthlyPaise,
      amount_display: `${formatPaise(schemeMonthlyPaise)}/mo`,
      months: 36,
    },
    primary_image: primaryImage(product),
    is_in_vault: options.vaultProductIds?.has(product.id) ?? false,
    stock_available: product.stockQuantity > 0,
    stock_label:
      product.stockQuantity > 0 && product.stockQuantity <= 3
        ? `Only ${product.stockQuantity} left`
        : null,
    has_ar: product.hasAr,
    badges: product.isFeatured ? ["new"] : [],
  };
}

export function buildGoalSuggestion(totalPaise: number) {
  const suggestedMonthlyPaise = Math.ceil(totalPaise / 36 / 100) * 100;
  const completionDate = new Date();
  completionDate.setMonth(completionDate.getMonth() + 36);

  return {
    suggested_monthly_paise: suggestedMonthlyPaise,
    suggested_monthly_display: `${formatPaise(suggestedMonthlyPaise)}/mo`,
    months_to_complete: 36,
    completion_date_display: completionDate.toLocaleDateString("en-IN", {
      month: "long",
      year: "numeric",
    }),
  };
}

export function buildAffordability(product: ProductWithRelations, totalPaise: number) {
  const suggestedMonthlyPaise = Math.ceil(totalPaise / 36 / 100) * 100;

  return {
    can_afford_now: false,
    percent_complete: 0,
    grams_needed_display: formatGoldGrams(product.weightGrams),
    suggested_monthly_paise: suggestedMonthlyPaise,
    suggested_monthly_display: `${formatPaise(suggestedMonthlyPaise)}/mo`,
    months_to_afford: 36,
  };
}
