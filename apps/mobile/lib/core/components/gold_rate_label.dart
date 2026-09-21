import 'package:flutter/material.dart';

import '../../components/feedback/loading_shimmer.dart';
import '../../components/icons/app_icon.dart';
import '../constants/colors.dart';
import '../constants/customer_copy.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import '../time/gold_rate_freshness.dart';
import '../time/ist_format.dart';
import '../time/server_clock.dart';
import '../utils/indian_format.dart';

enum GoldRateLabelVariant { light, dark }

/// Rate per gram with IST timestamp and truthful stale/offline states.
class GoldRateLabel extends StatelessWidget {
  const GoldRateLabel({
    super.key,
    required this.ratePaise,
    this.rateDisplayFallback,
    this.rateUpdatedAtIso,
    this.serverIsStale,
    this.refetchReturnedSameStaleRate = false,
    required this.purityLabel,
    required this.clock,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isOffline = false,
    this.showingCachedRate = false,
    this.compact = false,
    this.variant = GoldRateLabelVariant.light,
    this.onStaleRefresh,
  });

  final int? ratePaise;
  final String? rateDisplayFallback;
  final String? rateUpdatedAtIso;
  final bool? serverIsStale;
  final bool refetchReturnedSameStaleRate;
  final String purityLabel;
  final ServerClock clock;
  final bool isLoading;
  final bool isRefreshing;
  final bool isOffline;
  final bool showingCachedRate;
  final bool compact;
  final GoldRateLabelVariant variant;
  final VoidCallback? onStaleRefresh;

  bool get _canRefreshStale =>
      onStaleRefresh != null &&
      !isOffline &&
      !isRefreshing &&
      (_freshness == GoldRateFreshness.clientCacheStale ||
          _freshness == GoldRateFreshness.missingTimestamp);

  String? get _rateLine {
    if (ratePaise != null) {
      return '${IndianFormat.formatInrPaise(ratePaise!)}/g';
    }
    final fallback = rateDisplayFallback?.trim();
    if (fallback != null && fallback.isNotEmpty && fallback != '—') {
      return fallback;
    }
    return null;
  }

  GoldRateFreshness get _freshness => evaluateGoldRateFreshness(
    rateUpdatedAtIso: rateUpdatedAtIso,
    clock: clock,
    isOffline: isOffline,
    showingCachedRate: showingCachedRate,
    serverIsStale: serverIsStale,
    refetchReturnedSameStaleRate: refetchReturnedSameStaleRate,
  );

  String? get _asOfLine {
    if (_freshness == GoldRateFreshness.missingTimestamp) {
      return CustomerCopy.goldRateTimeUnavailable;
    }
    final parsed = DateTime.tryParse(rateUpdatedAtIso ?? '')?.toUtc();
    if (parsed == null) {
      return CustomerCopy.goldRateTimeUnavailable;
    }
    return IstFormat.formatRateAsOf(parsed);
  }

  String? get _statusLine {
    if (isRefreshing) {
      return CustomerCopy.goldRateRefreshing;
    }
    switch (_freshness) {
      case GoldRateFreshness.offlineCached:
        return CustomerCopy.goldRateOffline;
      case GoldRateFreshness.clientCacheStale:
        return CustomerCopy.goldRateClientCacheStale;
      case GoldRateFreshness.sourceStale:
        return CustomerCopy.goldRateSourceStale;
      case GoldRateFreshness.sourceUnchanged:
        return CustomerCopy.goldRateSourceUnchanged;
      case GoldRateFreshness.missingTimestamp:
        return CustomerCopy.goldRateTimeUnavailable;
      case GoldRateFreshness.fresh:
        return null;
    }
  }

  bool get _showStatusBanner =>
      _statusLine != null &&
      (_freshness != GoldRateFreshness.fresh || isRefreshing);

  String _semanticsLabel() {
    final rate = _rateLine ?? 'rate unavailable';
    final parts = <String>[
      'Gold rate $rate per gram',
      if (_asOfLine != null) _asOfLine!,
      if (_statusLine != null) _statusLine!,
      purityLabel,
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && _rateLine == null) {
      return Semantics(
        label: 'Loading gold rate',
        child: LoadingShimmer(
          width: double.infinity,
          height: 14,
          borderRadius: 2,
        ),
      );
    }

    final primaryColor = variant == GoldRateLabelVariant.dark
        ? AppColors.paper
        : AppColors.textPrimary;

    final rate = _rateLine;
    if (rate == null) {
      return Semantics(
        label: 'Gold rate unavailable, $purityLabel',
        child: Text(
          CustomerCopy.goldRateUnavailable(purityLabel),
          style: AppTypography.uiBodySM.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.2,
            height: 1.2,
          ),
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final asOf = _asOfLine;
    final status = _statusLine;
    final showBanner = _showStatusBanner;
    final headline = variant == GoldRateLabelVariant.dark
        ? 'RATE · '
        : '${CustomerCopy.goldRateHeadline} · ';

    return Semantics(
      label: _semanticsLabel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: AppTypography.uiBodySM.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.2,
                height: 1.25,
              ),
              children: [
                TextSpan(text: headline),
                TextSpan(
                  text: rate,
                  style: AppTypography.priceTabular.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                TextSpan(text: ' · $purityLabel'),
                if (asOf != null && !compact) TextSpan(text: ' · $asOf'),
              ],
            ),
          ),
          if (showBanner) ...[
            const SizedBox(height: AppSpacing.xxs),
            _RateStatusRow(
              message: status!,
              isRefreshing: isRefreshing,
              isOffline: _freshness == GoldRateFreshness.offlineCached,
              isActionable: _canRefreshStale,
              variant: variant,
              onTap: _canRefreshStale ? onStaleRefresh : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _RateStatusRow extends StatelessWidget {
  const _RateStatusRow({
    required this.message,
    required this.isRefreshing,
    required this.isOffline,
    required this.isActionable,
    required this.variant,
    this.onTap,
  });

  final String message;
  final bool isRefreshing;
  final bool isOffline;
  final bool isActionable;
  final GoldRateLabelVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isOffline || isActionable
        ? (variant == GoldRateLabelVariant.dark
              ? AppColors.goldLight
              : AppColors.warningFill)
        : (variant == GoldRateLabelVariant.dark
              ? AppColors.paper.withValues(alpha: 0.55)
              : AppColors.textMuted);

    final row = Row(
      children: [
        AppIcon(
          isRefreshing
              ? Icons.autorenew
              : isOffline
              ? Icons.cloud_off_outlined
              : Icons.schedule_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(
            message,
            style: AppTypography.uiBodySM.copyWith(
              color: color,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: onTap == null
          ? row
          : Semantics(
              button: true,
              label: '$message. Tap to refresh rate.',
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: row),
              ),
            ),
    );
  }
}
