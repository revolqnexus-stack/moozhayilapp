import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/buttons/secondary_button.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/product/product_image_placeholder.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/vault_item.dart';
import '../../../core/utils/indian_format.dart';

class DreamVaultCard extends StatelessWidget {
  const DreamVaultCard({
    super.key,
    required this.item,
    required this.onStartGoalTap,
    required this.onRemoveTap,
    this.onBuyTap,
    this.onViewGoalTap,
    this.compact = false,
  });

  final VaultItem item;
  final VoidCallback onStartGoalTap;
  final VoidCallback onRemoveTap;
  final VoidCallback? onBuyTap;
  final VoidCallback? onViewGoalTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _DreamVaultPreviewCard(item: item);
    }

    final product = item.product;
    final affordability = item.affordability;
    final goalAttached = item.goal != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.borderStrong, width: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: AppSpacing.x3l * 2 + AppSpacing.lg,
                width: double.infinity,
                child: product.primaryImage == null
                    ? const ProductImagePlaceholder()
                    : CachedNetworkImage(
                        imageUrl: product.primaryImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const LoadingShimmer(
                          width: double.infinity,
                          height: AppSpacing.x3l,
                        ),
                        errorWidget: (_, _, _) =>
                            const ProductImagePlaceholder(),
                      ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Semantics(
                  button: true,
                  label: 'Remove from Dream Vault',
                  child: GestureDetector(
                    onTap: onRemoveTap,
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.close,
                        color: AppColors.pureWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTypography.productName),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        product.category?.name ?? 'Jewellery',
                        style: AppTypography.uiCaption,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        product.price.totalDisplay,
                        style: AppTypography.priceMD,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _MiniProgressRing(
                      percent: affordability.percentComplete,
                      size: AppSpacing.xxl,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      affordability.gramsNeededDisplay,
                      style: AppTypography.uiMicro,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: _ActionRow(
              canAffordNow: affordability.canAffordNow,
              goalAttached: goalAttached,
              monthlyHint: affordability.suggestedMonthlyDisplay,
              months: affordability.monthsToAfford,
              onBuyTap: onBuyTap,
              onStartGoalTap: onStartGoalTap,
              onViewGoalTap: onViewGoalTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamVaultPreviewCard extends StatelessWidget {
  const _DreamVaultPreviewCard({required this.item});

  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return SizedBox(
      width: AppSpacing.x3l + AppSpacing.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppSpacing.x3l,
            width: double.infinity,
            child: product.primaryImage == null
                ? const ProductImagePlaceholder()
                : CachedNetworkImage(
                    imageUrl: product.primaryImage!,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ProductImagePlaceholder(),
                  ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            product.name,
            style: AppTypography.uiCaption.copyWith(
              fontFamily: AppTypography.productName.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              _MiniProgressRing(
                percent: item.affordability.percentComplete,
                size: AppSpacing.lg + AppSpacing.xs,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  '${_currentGrams(product.weightGrams)} of ${product.weightDisplay}',
                  style: AppTypography.uiMicro,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _currentGrams(String weightGrams) {
    return IndianFormat.formatGramsPercentOf(
      weightGrams,
      item.affordability.percentComplete,
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.canAffordNow,
    required this.goalAttached,
    required this.monthlyHint,
    required this.months,
    this.onBuyTap,
    required this.onStartGoalTap,
    this.onViewGoalTap,
  });

  final bool canAffordNow;
  final bool goalAttached;
  final String monthlyHint;
  final int months;
  final VoidCallback? onBuyTap;
  final VoidCallback onStartGoalTap;
  final VoidCallback? onViewGoalTap;

  @override
  Widget build(BuildContext context) {
    if (canAffordNow) {
      return PrimaryButton(
        label: 'Buy With My Gold',
        isFullWidth: true,
        onTap: onBuyTap,
      );
    }

    if (goalAttached) {
      return GhostButton(label: 'View Plan →', onTap: onViewGoalTap);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecondaryButton(
          label: 'Start Aura Plan →',
          onTap: onStartGoalTap,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '$monthlyHint for $months months',
          style: AppTypography.uiCaption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MiniProgressRing extends StatelessWidget {
  const _MiniProgressRing({required this.percent, required this.size});

  final int percent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = (percent.clamp(0, 100)) / 100;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            backgroundColor: AppColors.smokeLine,
            color: AppColors.antiqueGold,
          ),
          Text('$percent%', style: AppTypography.uiMicro),
        ],
      ),
    );
  }
}
