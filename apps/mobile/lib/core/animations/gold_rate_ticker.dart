import 'package:flutter/material.dart';
import '../constants/animations.dart';
import '../constants/colors.dart';

/// Premium gold rate ticker: digits roll vertically like a market ticker.
/// Shows rate increase/decrease with subtle gold/red indicator.
class GoldRateTicker extends StatefulWidget {
  const GoldRateTicker({
    super.key,
    required this.rate,
    required this.previousRate,
    this.style,
    this.showChangeIndicator = true,
  });

  final String rate; // e.g., "₹7,234.50"
  final String previousRate;
  final TextStyle? style;
  final bool showChangeIndicator;

  @override
  State<GoldRateTicker> createState() => _GoldRateTickerState();
}

class _GoldRateTickerState extends State<GoldRateTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.rateRoll,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(GoldRateTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rate != widget.rate) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  RateChange get _change {
    final prev = _parseRate(widget.previousRate);
    final curr = _parseRate(widget.rate);
    if (curr > prev) return RateChange.increased;
    if (curr < prev) return RateChange.decreased;
    return RateChange.none;
  }

  double _parseRate(String rate) {
    return double.tryParse(rate.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.lerp(
                  Alignment.bottomCenter,
                  Alignment.center,
                  AnimationPresets.rateRollCurve.transform(_controller.value),
                )!,
                heightFactor: 1.0,
                child: Text(
                  widget.rate,
                  style:
                      widget.style ??
                      TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _change == RateChange.increased
                            ? AppColors.gold
                            : _change == RateChange.decreased
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        letterSpacing: 0.02,
                      ),
                ),
              ),
            );
          },
        ),
        if (widget.showChangeIndicator && _change != RateChange.none) ...[
          const SizedBox(width: 6),
          _RateChangeIndicator(change: _change),
        ],
      ],
    );
  }
}

enum RateChange { increased, decreased, none }

class _RateChangeIndicator extends StatefulWidget {
  const _RateChangeIndicator({required this.change});

  final RateChange change;

  @override
  State<_RateChangeIndicator> createState() => _RateChangeIndicatorState();
}

class _RateChangeIndicatorState extends State<_RateChangeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncrease = widget.change == RateChange.increased;
    final color = isIncrease ? AppColors.gold : AppColors.textSecondary;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3 * (1 - _glow.value)),
                blurRadius: 4 * (1 - _glow.value),
              ),
            ],
          ),
          child: Icon(
            isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: color,
          ),
        );
      },
    );
  }
}

/// Subtle gold bell ring animation for rate alerts.
class GoldBellAnimation extends StatefulWidget {
  const GoldBellAnimation({super.key, this.size = 24});

  final double size;

  @override
  State<GoldBellAnimation> createState() => _GoldBellAnimationState();
}

class _GoldBellAnimationState extends State<GoldBellAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.rateAlert,
    );

    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.15), weight: 1),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: -0.15),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _scale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.1, end: 1.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(
            angle: _rotation.value,
            child: Icon(
              Icons.notifications,
              size: widget.size,
              color: AppColors.gold,
            ),
          ),
        );
      },
    );
  }
}
