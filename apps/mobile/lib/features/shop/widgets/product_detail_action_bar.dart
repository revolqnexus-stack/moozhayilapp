import 'package:flutter/material.dart';

import '../../../core/animations/premium_pressable.dart';

import '../../../components/icons/app_icon.dart';

import '../../../components/icons/app_icons.dart';

import '../../../components/product/vault_icon_button.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/motion.dart';

import '../../../core/constants/spacing.dart';

import '../../../core/constants/typography.dart';

import '../../../core/models/product.dart';

/// Anchored purchase rail for product detail — sits flush at the screen bottom.

class ProductDetailActionBar extends StatelessWidget {
  const ProductDetailActionBar({
    super.key,

    required this.product,

    required this.isInVault,

    required this.isOutOfStock,

    required this.isAddingToBag,

    this.showBagAddedAck = false,

    required this.onAddToBag,

    required this.onBookVideoCall,

    required this.onToggleVault,

    this.includeShellNavClearance = false,
  });

  final Product product;

  final bool isInVault;

  final bool isOutOfStock;

  final bool isAddingToBag;

  final bool showBagAddedAck;

  final VoidCallback? onAddToBag;

  final VoidCallback onBookVideoCall;

  final VoidCallback? onToggleVault;

  final bool includeShellNavClearance;

  static double bottomInset(BuildContext context, {bool includeNav = false}) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    if (!includeNav) return safeBottom;

    return AppSpacing.shellBottomNavHeight + safeBottom;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = includeShellNavClearance
        ? bottomInset(context, includeNav: true)
        : MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgWhite,

        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.85),

            width: 0.5,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),

            blurRadius: 12,

            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.homeScreenPadding,

            AppSpacing.sm,

            AppSpacing.homeScreenPadding,

            bottomPadding,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    product.price.totalDisplay,

                    style: AppTypography.uiBodyMD.copyWith(
                      fontWeight: FontWeight.w600,

                      fontSize: 17,

                      color: AppColors.textPrimary,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'Want to see this piece live?',

                    style: AppTypography.uiCaption.copyWith(
                      color: AppColors.textSecondary,

                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  Expanded(
                    child: _SecondaryActionButton(
                      label: 'Book Video Call',

                      icon: AppIcons.videoCall,

                      onTap: onBookVideoCall,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Expanded(
                    flex: 2,

                    child: _PrimaryActionButton(
                      label: isOutOfStock ? 'Notify me' : 'Add to Bag',

                      isDisabled: isOutOfStock || isAddingToBag,

                      isLoading: isAddingToBag,

                      showSuccessAck: showBagAddedAck,

                      onTap: onAddToBag,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  VaultIconButton(
                    isInVault: isInVault,

                    onTap: isOutOfStock ? null : onToggleVault,

                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,

    required this.isDisabled,

    required this.isLoading,

    this.showSuccessAck = false,

    required this.onTap,
  });

  final String label;

  final bool isDisabled;

  final bool isLoading;

  final bool showSuccessAck;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = !isDisabled && onTap != null;

    return PremiumPressable(
      onTap: enabled ? onTap : null,

      scaleEnd: 0.98,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),

        height: 46,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: enabled ? AppColors.brandBurgundy : AppColors.disabledBg,

          border: Border.all(
            color: enabled
                ? AppColors.gold.withValues(alpha: 0.35)
                : Colors.transparent,

            width: 0.5,
          ),
        ),

        child: isLoading
            ? const SizedBox(
                width: 20,

                height: 20,

                child: CircularProgressIndicator(
                  strokeWidth: 2,

                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.cream),
                ),
              )
            : AnimatedSwitcher(
                duration: AppMotion.stateTransition,
                switchInCurve: AppMotion.entrance,
                switchOutCurve: AppMotion.exit,
                child: showSuccessAck
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('bag-added'),
                        color: AppColors.cream,
                        size: 22,
                      )
                    : Text(
                        label.toUpperCase(),
                        key: const ValueKey('bag-label'),
                        style: AppTypography.buttonLabelSM.copyWith(
                          color: enabled
                              ? AppColors.cream
                              : AppColors.disabledText,
                          letterSpacing: 9 * 0.18,
                        ),
                      ),
              ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,

    required this.icon,

    required this.onTap,
  });

  final String label;

  final IconData icon;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      onTap: onTap,

      scaleEnd: 0.98,

      child: Container(
        height: 46,

        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),

        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.brandBurgundy.withValues(alpha: 0.45),

            width: 0.5,
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            AppIcon(icon, size: 16, color: AppColors.brandBurgundy),

            const SizedBox(width: 4),

            Flexible(
              child: Text(
                label,

                maxLines: 2,

                textAlign: TextAlign.center,

                style: AppTypography.uiCaption.copyWith(
                  fontWeight: FontWeight.w600,

                  color: AppColors.brandBurgundy,

                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
