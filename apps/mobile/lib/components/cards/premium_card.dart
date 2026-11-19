import 'package:flutter/material.dart';

import '../../core/constants/animations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';
import '../../core/constants/shadows.dart';
import '../../core/constants/spacing.dart';

/// Premium editorial card.
///
/// Soft rounded corners, a hairline warm border, and a gentle shadow.
/// On press, a faint gold glow appears around the card — like a jewellery
/// box catching the light. Use for product cards, scheme cards, and
/// editorial panels that should feel tactile.
///
/// If [onTap] is null the card renders in a disabled, flat state.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor = AppColors.border,
    this.shadow = AppShadows.sm,
    this.padding = AppSpacing.cardPaddingMD,
    this.radius = AppRadius.card,
    this.pressed = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color borderColor;
  final BoxShadow shadow;
  final double padding;
  final double radius;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final interactive = onTap != null;
    final glow = pressed && interactive;

    return Semantics(
      button: interactive,
      enabled: interactive,
      child: AnimatedContainer(
        duration: AppAnimations.cardPress,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: glow
                ? AppColors.gold.withValues(alpha: 0.55)
                : borderColor,
            width: glow ? 1.2 : 0.5,
          ),
          boxShadow: interactive
              ? [
                  shadow,
                  if (glow)
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                ]
              : [shadow],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            splashColor: AppColors.gold.withValues(alpha: 0.10),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A premium card variant with a subtle gold top border — used for
/// hero sections, featured products, and scheme panels.
class PremiumCardGold extends PremiumCard {
  const PremiumCardGold({
    super.key,
    required super.child,
    super.onTap,
    super.shadow = AppShadows.md,
    super.padding = AppSpacing.cardPaddingLG,
    super.radius = AppRadius.card,
    super.pressed = false,
  }) : super(borderColor: AppColors.borderGold);
}
