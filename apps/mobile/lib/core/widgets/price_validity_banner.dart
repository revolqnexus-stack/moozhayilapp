import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../constants/colors.dart';
import '../constants/customer_copy.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import '../pricing/price_validity_guard.dart';
import '../time/ist_format.dart';

class PriceValidityBanner extends StatefulWidget {
  const PriceValidityBanner({
    super.key,
    required this.guard,
    this.onRefresh,
    this.isRefreshing = false,
  });

  final PriceValidityGuard guard;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  @override
  State<PriceValidityBanner> createState() => _PriceValidityBannerState();
}

class _PriceValidityBannerState extends State<PriceValidityBanner> {
  Timer? _timer;
  String? _lastAnnounced;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        _maybeAnnounce();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _maybeAnnounce() {
    if (!mounted || widget.guard.isExpired) {
      return;
    }
    final remaining = widget.guard.remaining;
    String? label;
    if (remaining <= const Duration(minutes: 1) &&
        remaining > const Duration(seconds: 59)) {
      label = 'One minute left on your rate lock';
    } else if (remaining <= const Duration(minutes: 3) &&
        remaining > const Duration(minutes: 2, seconds: 59)) {
      label = 'Three minutes left on your rate lock';
    }
    if (label != null && label != _lastAnnounced) {
      _lastAnnounced = label;
      if (MediaQuery.maybeSupportsAnnounceOf(context) ?? false) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          label,
          Directionality.of(context),
        );
      }
    }
  }

  String _countdownLabel() {
    if (widget.isRefreshing) {
      return CustomerCopy.priceLockRefreshing;
    }
    if (widget.guard.isExpired) {
      return CustomerCopy.priceLockExpired;
    }
    if (widget.guard.isInFinalMinutes) {
      final totalSeconds = widget.guard.remaining.inSeconds;
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return CustomerCopy.priceLockCountdownMmSs(minutes, seconds);
    }
    return CustomerCopy.priceLockUntilIst(
      IstFormat.formatTimeIst(widget.guard.validUntilUtc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expired = widget.guard.isExpired;
    final color = expired ? AppColors.warningFill : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.pearl,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            expired ? Icons.schedule_outlined : Icons.lock_clock_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _countdownLabel(),
              style: AppTypography.uiBodySM.copyWith(color: color),
            ),
          ),
          if (expired && widget.onRefresh != null)
            TextButton(
              onPressed: widget.isRefreshing ? null : widget.onRefresh,
              child: Text(CustomerCopy.priceLockRefresh),
            ),
        ],
      ),
    );
  }
}
