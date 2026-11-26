import 'package:flutter/material.dart';

import '../../../components/cards/premium_card.dart';
import '../../../components/product/vault_icon_button.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/premium_pressable.dart';

import '../../core/constants/motion.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';

import '../../core/constants/typography.dart';

import '../../core/models/product.dart';

import '../../core/utils/catalog_imagery.dart';

import '../editorial/editorial_image.dart';

enum ProductCardVariant { grid, list, horizontal }

/// Image-first catalogue card with purity, weight, and optional Dream Vault heart.
///
/// Wrapped in [PremiumCard] for soft corners, a warm border, and a faint
/// gold glow on press. Each card accepts an optional [staggerDelay] so
/// grids can reveal one card after the next.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.product,
    this.isLoading = false,
    this.variant = ProductCardVariant.grid,
    this.onTap,
    this.onVaultTap,
    this.staggerDelay = Duration.zero,
  });

  final Product? product;

  final bool isLoading;

  final ProductCardVariant variant;

  final VoidCallback? onTap;

  final VoidCallback? onVaultTap;

  /// Delay before the card fades/slides in — used for staggered grid reveals.
  final Duration staggerDelay;

  @override
  Widget build(BuildContext context) {
    if (isLoading || product == null) {
      return const SizedBox.shrink();
    }

    final item = product!;

    return Semantics(
      button: true,
      label: item.name,
      child: FadeSlideIn(
        delay: staggerDelay,
        duration: AppMotion.cardReveal,
        offsetY: 16,
        curve: Curves.easeOutCubic,
        child: PremiumCard(
          onTap: onTap,
          borderColor: AppColors.borderGold.withValues(alpha: 0.5),
          padding: variant == ProductCardVariant.horizontal
              ? AppSpacing.cardPaddingSM
              : AppSpacing.cardPaddingMD,
          child: PremiumPressable(
            onTap: onTap,
            child: variant == ProductCardVariant.list
                ? _ListProductContent(product: item, onVaultTap: onVaultTap)
                : _StackedProductContent(
                    product: item,
                    variant: variant,
                    onVaultTap: onVaultTap,
                  ),
          ),
        ),
      ),
    );
  }
}

class _StackedProductContent extends StatelessWidget {
  const _StackedProductContent({
    required this.product,
    required this.variant,
    this.onVaultTap,
  });

  final Product product;
  final ProductCardVariant variant;
  final VoidCallback? onVaultTap;

  @override
  Widget build(BuildContext context) {
    final image = _ProductImage(product: product, onVaultTap: onVaultTap);

    if (variant == ProductCardVariant.horizontal) {
      return SizedBox(
        width: AppSpacing.x3l * 3 + AppSpacing.lg,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: image),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: _ProductText(product: product),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: 3 / 4, child: image),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _ProductText(product: product),
        ),
      ],
    );
  }
}

class _ListProductContent extends StatelessWidget {
  const _ListProductContent({required this.product, this.onVaultTap});

  final Product product;
  final VoidCallback? onVaultTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSpacing.x3l + AppSpacing.xl,
          height: AppSpacing.x3l + AppSpacing.xl,
          child: _ProductImage(product: product, onVaultTap: onVaultTap),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _ProductText(product: product)),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, this.onVaultTap});

  final Product product;
  final VoidCallback? onVaultTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.pearl,
      child: Stack(
        fit: StackFit.expand,
        children: [
          EditorialImage(
            url: CatalogImagery.resolveProduct(
              product.primaryImage,
              product.id,
            ),
          ),
          if (!product.stockAvailable)
            ColoredBox(
              color: AppColors.ink.withValues(alpha: 0.35),
              child: Center(
                child: Text(
                  'Out of stock',
                  style: AppTypography.uiLabel.copyWith(color: AppColors.paper),
                ),
              ),
            ),
          if (product.badges.contains('new'))
            Positioned(
              left: AppSpacing.xs,
              top: AppSpacing.xs,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.32),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'NEW',
                  style: AppTypography.uiMicro.copyWith(
                    fontSize: 7,
                    color: AppColors.ink,
                    letterSpacing: 7 * 0.18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (onVaultTap != null)
            Positioned(
              right: AppSpacing.xs,
              top: AppSpacing.xs,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.warmIvory.withValues(alpha: 0.94),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: VaultIconButton(
                  isInVault: product.isInVault,
                  onTap: onVaultTap,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductText extends StatelessWidget {
  const _ProductText({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.name,
          style: AppTypography.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${product.purityDisplay} · ${product.weightDisplay}',
          style: AppTypography.uiCaption.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          product.price.totalDisplay,
          style: AppTypography.priceMD.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
