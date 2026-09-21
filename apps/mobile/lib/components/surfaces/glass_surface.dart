import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/animations/premium_pressable.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/shadows.dart';

/// Frosted glass panel — nav bars, floating CTAs, scheme cards.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blurSigma = 16,
    this.borderRadius = BorderRadius.zero,
    this.showTopBorder = false,
    this.showBottomBorder = false,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final BorderRadius borderRadius;
  final bool showTopBorder;
  final bool showBottomBorder;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: elevated
            ? const [AppShadows.top]
            : const [
                BoxShadow(
                  color: Color(0x0A1A1612),
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.ivory.withValues(alpha: 0.92),
              border: Border(
                top: showTopBorder
                    ? BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        width: 0.5,
                      )
                    : BorderSide.none,
                bottom: showBottomBorder
                    ? BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        width: 0.5,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}

/// Raised luxury card — soft shadow, pearl well, hairline edge highlight.
class LuxuryCard extends StatelessWidget {
  const LuxuryCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.ivory,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.12),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return PremiumPressable(onTap: onTap, scaleEnd: 0.985, child: card);
  }
}
