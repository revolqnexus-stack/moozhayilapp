import 'package:flutter/material.dart';

import '../../../core/animations/animated_counter.dart';
import '../../../core/animations/fade_slide_in.dart';
import '../../../core/animations/gold_shimmer_text.dart';
import '../../../core/utils/indian_format.dart';
import '../../../core/components/gold_rate_label.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/motion.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/gold_balance.dart';
import '../../../core/time/server_clock.dart';

/// Hero band on My Gold — ink ground, gold shimmer balance.
class MyGoldHero extends StatelessWidget {
  const MyGoldHero({
    super.key,
    required this.balance,
    required this.clock,
    this.isOffline = false,
    this.isRefreshing = false,
    this.isLoading = false,
    this.onStaleRefresh,
  });

  final GoldBalance balance;
  final ServerClock clock;
  final bool isOffline;
  final bool isRefreshing;
  final bool isLoading;
  final VoidCallback? onStaleRefresh;

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
          _BalanceGramsDisplay(balance: balance, isLoading: isLoading),
          const SizedBox(height: AppSpacing.xxs),
          FadeSlideIn(
            delay: const Duration(milliseconds: 180),
            duration: AppMotion.normal,
            offsetY: 6,
            child: _BalanceValueDisplay(balance: balance, isLoading: isLoading),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeSlideIn(
            delay: const Duration(milliseconds: 260),
            duration: AppMotion.normal,
            offsetY: 4,
            child: GoldRateLabel(
              ratePaise: balance.rateUsed.ratePaise,
              rateDisplayFallback: balance.rateUsed.rateDisplay,
              rateUpdatedAtIso: balance.rateUsed.updatedAt,
              serverIsStale: balance.rateUsed.isStale,
              purityLabel: balance.rateUsed.purity.toUpperCase(),
              clock: clock,
              isOffline: isOffline,
              isRefreshing: isRefreshing,
              isLoading: isLoading,
              showingCachedRate: isOffline,
              variant: GoldRateLabelVariant.dark,
              onStaleRefresh: onStaleRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceGramsDisplay extends StatelessWidget {
  const _BalanceGramsDisplay({required this.balance, required this.isLoading});

  final GoldBalance balance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.displayLG.copyWith(color: AppColors.paper);
    if (isLoading) {
      return GoldShimmerText(text: balance.totalGramsDisplay, style: style);
    }

    final grams = double.tryParse(balance.totalGrams) ?? 0;
    return AnimatedCounter(
      value: grams,
      formatter: (v) => IndianFormat.formatGrams(v.toStringAsFixed(4)),
      style: style,
      builder: (text, textStyle) =>
          GoldShimmerText(text: text, style: textStyle ?? style),
    );
  }
}

class _BalanceValueDisplay extends StatelessWidget {
  const _BalanceValueDisplay({required this.balance, required this.isLoading});

  final GoldBalance balance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.uiBodySM.copyWith(
      color: AppColors.paper.withValues(alpha: 0.55),
    );
    if (isLoading) {
      return Text(balance.totalValueDisplay, style: style);
    }

    return AnimatedCounter(
      value: balance.totalValuePaise.toDouble(),
      formatter: (v) => IndianFormat.formatInrPaise(v.round()),
      style: style,
    );
  }
}
