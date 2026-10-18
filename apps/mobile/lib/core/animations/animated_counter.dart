import 'package:flutter/material.dart';

import '../constants/animations.dart';
import '../utils/motion_preferences.dart';

/// Animates a numeric value from its previous value (or from zero on first
/// mount) to [value], rendering the result via [formatter].
///
/// If [builder] is provided it receives the formatted string + [style] and
/// must return a widget — use this to wrap the text in [GoldShimmerText].
/// If [builder] is null the widget renders a plain [Text].
///
/// Used for the gold balance count-up on My Gold screen and the checkout
/// discount roll-down animation.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = AppAnimations.goldCountUp,
    this.curve = Curves.easeOutCubic,
    this.beginAt = 0.0,
    this.builder,
  });

  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  /// Override the starting value on first mount. Defaults to 0.
  final double beginAt;

  /// Optional custom renderer. Receives (formattedText, style) → Widget.
  final Widget Function(String text, TextStyle? style)? builder;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: widget.beginAt,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!premiumMotionEnabled(context)) {
        _controller.value = 1.0;
        return;
      }
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      if (!premiumMotionEnabled(context)) {
        _animation = AlwaysStoppedAnimation<double>(widget.value);
        _controller.value = 1.0;
        return;
      }
      final fromValue = _animation.value;
      _animation = Tween<double>(
        begin: fromValue,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller
        ..reset()
        ..forward();
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
      animation: _animation,
      builder: (_, _) {
        final formatted = widget.formatter(_animation.value);
        if (widget.builder != null) {
          return widget.builder!(formatted, widget.style);
        }
        return Text(formatted, style: widget.style);
      },
    );
  }
}
