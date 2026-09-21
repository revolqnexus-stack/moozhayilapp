import 'package:flutter/material.dart';

import '../../../core/animations/fade_slide_in.dart';
import '../../../core/animations/gold_shimmer_text.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/motion.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/gold_balance.dart';

/// Hero band on My Gold — ink ground, gold shimmer balance.
class MyGoldHero extends StatelessWidget {
  const MyGoldHero({super.key, required this.balance});

  final GoldBalance balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR GOLD BALANCE',
            style: AppTypography.uiMicro.copyWith(
              color: AppColors.gold,
              letterSpacing: 9 * 0.28,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GoldShimmerText(
            text: balance.totalGramsDisplay,
            style: AppTypography.displayLG.copyWith(color: AppColors.paper),
          ),
          const SizedBox(height: AppSpacing.xxs),
          FadeSlideIn(
            delay: const Duration(milliseconds: 180),
            duration: AppMotion.normal,
            offsetY: 6,
            child: Text(
              balance.totalValueDisplay,
              style: AppTypography.uiBodySM.copyWith(
                color: AppColors.paper.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeSlideIn(
            delay: const Duration(milliseconds: 260),
            duration: AppMotion.normal,
            offsetY: 4,
            child: Text(
              balance.rateUsed.rateDisplay.toUpperCase(),
              style: AppTypography.uiMicro.copyWith(
                color: AppColors.goldLight,
                letterSpacing: 8 * 0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
