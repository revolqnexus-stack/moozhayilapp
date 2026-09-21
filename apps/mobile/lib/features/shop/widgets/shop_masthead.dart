import 'package:flutter/material.dart';

import '../../../core/components/gold_rate_label.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/time/server_clock.dart';
import 'shop_search_field.dart';
import 'shop_section.dart';

/// Compact Shop tab header — catalogue identity, not a marketing hero.
class ShopMasthead extends StatelessWidget {
  const ShopMasthead({
    super.key,
    required this.onSearchTap,
    required this.clock,
    this.ratePaise,
    this.rateDisplay,
    this.rateUpdatedAtIso,
    this.serverIsStale,
    this.isRateLoading = false,
    this.isRateRefreshing = false,
    this.isOffline = false,
    this.onRefreshRate,
    this.pieceCount,
  });

  final VoidCallback onSearchTap;
  final ServerClock clock;
  final int? ratePaise;
  final String? rateDisplay;
  final String? rateUpdatedAtIso;
  final bool? serverIsStale;
  final bool isRateLoading;
  final bool isRateRefreshing;
  final bool isOffline;
  final VoidCallback? onRefreshRate;
  final int? pieceCount;

  @override
  Widget build(BuildContext context) {
    return ShopSectionInset(
      top: 20,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop',
                      style: AppTypography.headingLG.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        height: 1.05,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pieceCount != null
                          ? '$pieceCount hallmarked pieces · priced from the daily gold rate'
                          : 'Hallmarked jewellery · priced from the daily gold rate',
                      style: AppTypography.uiBodySM.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 140,
                child: GoldRateLabel(
                  ratePaise: ratePaise,
                  rateDisplayFallback: rateDisplay,
                  rateUpdatedAtIso: rateUpdatedAtIso,
                  serverIsStale: serverIsStale,
                  purityLabel: '22KT',
                  clock: clock,
                  isLoading: isRateLoading,
                  isRefreshing: isRateRefreshing,
                  isOffline: isOffline,
                  showingCachedRate: isOffline,
                  compact: true,
                  onStaleRefresh: onRefreshRate,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ShopSearchEntry(onTap: onSearchTap),
        ],
      ),
    );
  }
}
