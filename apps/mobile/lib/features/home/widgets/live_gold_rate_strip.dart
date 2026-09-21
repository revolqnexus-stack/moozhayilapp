import 'package:flutter/material.dart';

import '../../../core/animations/gold_pulse.dart';
import '../../../core/components/gold_rate_label.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/motion.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/time/server_clock.dart';

/// Daily gold rate strip — slim premium information band.
class LiveGoldRateStrip extends StatefulWidget {
  const LiveGoldRateStrip({
    super.key,
    this.ratePaise,
    this.rateDisplay,
    this.rateUpdatedAtIso,
    this.serverIsStale,
    required this.clock,
    this.purityLabel = '22KT',
    this.isLoading = false,
    this.isRefreshing = false,
    this.isOffline = false,
    this.onRefreshRate,
  });

  final int? ratePaise;
  final String? rateDisplay;
  final String? rateUpdatedAtIso;
  final bool? serverIsStale;
  final ServerClock clock;
  final String purityLabel;
  final bool isLoading;
  final bool isRefreshing;
  final bool isOffline;
  final VoidCallback? onRefreshRate;

  @override
  State<LiveGoldRateStrip> createState() => _LiveGoldRateStripState();
}

class _LiveGoldRateStripState extends State<LiveGoldRateStrip>
    with SingleTickerProviderStateMixin {
  int? _cachedRatePaise;
  String? _cachedRateDisplay;
  String? _cachedUpdatedAt;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulse = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: AppMotion.standard),
    );
  }

  @override
  void didUpdateWidget(LiveGoldRateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ratePaise != null) {
      _cachedRatePaise = widget.ratePaise;
    }
    if (widget.rateDisplay != null && widget.rateDisplay!.isNotEmpty) {
      _cachedRateDisplay = widget.rateDisplay;
    }
    if (widget.rateUpdatedAtIso != null &&
        widget.rateUpdatedAtIso!.isNotEmpty) {
      _cachedUpdatedAt = widget.rateUpdatedAtIso;
    }

    final hadRate = oldWidget.ratePaise != null || _cachedRatePaise != null;
    final hasRate = widget.ratePaise != null || _cachedRatePaise != null;
    if ((!widget.isLoading && oldWidget.isLoading && hasRate) ||
        (hadRate &&
            hasRate &&
            oldWidget.ratePaise != widget.ratePaise &&
            !widget.isLoading)) {
      _pulseController.forward(from: 0).then((_) {
        if (mounted) _pulseController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _showingCachedRate =>
      widget.isOffline &&
      (widget.ratePaise != null ||
          _cachedRatePaise != null ||
          widget.rateDisplay != null ||
          _cachedRateDisplay != null);

  @override
  Widget build(BuildContext context) {
    final ratePaise = widget.ratePaise ?? _cachedRatePaise;
    final rateDisplay = widget.rateDisplay ?? _cachedRateDisplay;
    final updatedAt = widget.rateUpdatedAtIso ?? _cachedUpdatedAt;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.pearl,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.55),
            width: 0.35,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.homeScreenPadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 2,
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.brandBurgundy,
                    AppColors.gold.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GoldRateLabel(
                ratePaise: ratePaise,
                rateDisplayFallback: rateDisplay,
                rateUpdatedAtIso: updatedAt,
                serverIsStale: widget.serverIsStale,
                purityLabel: widget.purityLabel,
                clock: widget.clock,
                isLoading:
                    widget.isLoading &&
                    ratePaise == null &&
                    rateDisplay == null,
                isRefreshing: widget.isRefreshing,
                isOffline: widget.isOffline,
                showingCachedRate: _showingCachedRate,
                compact: true,
                onStaleRefresh: widget.onRefreshRate,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (widget.isLoading && !widget.isRefreshing)
              const GoldPulse(size: 7)
            else
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
