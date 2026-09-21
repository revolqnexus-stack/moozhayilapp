import 'package:flutter/material.dart';

import '../constants/animations.dart';
import '../constants/colors.dart';
import '../utils/indian_format.dart';

/// Premium number counter for gold grams that counts upward smoothly.
/// Used when grams are credited (contributions, bonuses, adjustments).
class GramsCounterAnimation extends StatefulWidget {
  const GramsCounterAnimation({
    super.key,
    required this.endValue,
    this.startValue = 0.0,
    this.style,
    this.suffix = 'g',
    this.decimals = 1,
  });

  final double startValue;
  final double endValue;
  final TextStyle? style;
  final String suffix;
  final int decimals;

  @override
  State<GramsCounterAnimation> createState() => _GramsCounterAnimationState();
}

class _GramsCounterAnimationState extends State<GramsCounterAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _counter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.gramsCredit,
    );

    _counter = Tween<double>(begin: widget.startValue, end: widget.endValue)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: AnimationPresets.gramsCreditCurve,
          ),
        );

    _controller.forward();
  }

  @override
  void didUpdateWidget(GramsCounterAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endValue != widget.endValue) {
      _counter = Tween<double>(begin: oldWidget.endValue, end: widget.endValue)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: AnimationPresets.gramsCreditCurve,
            ),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _counter,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppColors.gold, AppColors.goldLight, AppColors.gold],
            stops: [0.0, _controller.value, 1.0],
          ).createShader(bounds),
          child: Text(
            '${IndianFormat.formatGramsDouble(_counter.value, includeSuffix: false)}${widget.suffix}',
            style:
                widget.style ??
                const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.02,
                ),
          ),
        );
      },
    );
  }
}

/// Amount counter (paise to rupees) with smooth counting.
class AmountCounterAnimation extends StatefulWidget {
  const AmountCounterAnimation({
    super.key,
    required this.endAmountPaise,
    this.startAmountPaise = 0,
    this.style,
    this.prefix = '₹',
  });

  final int startAmountPaise;
  final int endAmountPaise;
  final TextStyle? style;
  final String prefix;

  @override
  State<AmountCounterAnimation> createState() => _AmountCounterAnimationState();
}

class _AmountCounterAnimationState extends State<AmountCounterAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _counter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.numberCounter,
    );

    _counter = IntTween(
      begin: widget.startAmountPaise,
      end: widget.endAmountPaise,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AmountCounterAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endAmountPaise != widget.endAmountPaise) {
      _counter = IntTween(
        begin: oldWidget.endAmountPaise,
        end: widget.endAmountPaise,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatAmount(int paise) {
    if (widget.prefix != IndianFormat.rupeeSymbol) {
      return '${widget.prefix}${IndianFormat.formatInrPaise(paise).replaceFirst(IndianFormat.rupeeSymbol, '')}';
    }
    return IndianFormat.formatInrPaise(paise);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _counter,
      builder: (context, child) {
        return Text(
          _formatAmount(_counter.value),
          style:
              widget.style ??
              const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                letterSpacing: 0.02,
              ),
        );
      },
    );
  }
}
