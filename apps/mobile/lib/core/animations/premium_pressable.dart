import 'package:flutter/material.dart';

import '../constants/motion.dart';
import '../utils/app_haptics.dart';
import '../utils/motion_preferences.dart';

/// Tactile press feedback for premium cards, rows, and tappable surfaces.
class PremiumPressable extends StatefulWidget {
  const PremiumPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleEnd = AppMotion.cardPressScale,
    this.duration = AppMotion.pressDuration,
    this.enableHaptic = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleEnd;
  final Duration duration;
  final bool enableHaptic;
  final String? semanticLabel;

  @override
  State<PremiumPressable> createState() => _PremiumPressableState();
}

class _PremiumPressableState extends State<PremiumPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(
      begin: 1,
      end: widget.scaleEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.press));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    if (!premiumMotionEnabled(context)) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  void _onTap() {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) {
      AppHaptics.light();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final child = ScaleTransition(scale: _scale, child: widget.child);

    if (widget.onTap == null) return child;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
