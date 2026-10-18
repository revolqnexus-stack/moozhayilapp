import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/motion.dart';

/// Scales a count badge 0.85 → 1.1 → 1.0 when [count] changes.
class AnimatedBadge extends StatefulWidget {
  const AnimatedBadge({
    super.key,
    required this.count,
    this.accentColor = AppColors.gold,
    this.textColor = AppColors.ink,
  });

  final int count;
  final Color accentColor;
  final Color textColor;

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.normal);
    _scale = _buildScale();
  }

  Animation<double> _buildScale() {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.65,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 1.0,
        ).chain(CurveTween(curve: AppMotion.standard)),
        weight: 45,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count && widget.count > 0) {
      _scale = _buildScale();
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
    if (widget.count <= 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _controller.isAnimating ? _scale.value : 1.0,
        child: child,
      ),
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: widget.accentColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          widget.count > 99 ? '99+' : widget.count.toString(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: widget.textColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Small gold pulse dot for Dream Vault saved indicator.
class AnimatedPulseDot extends StatefulWidget {
  const AnimatedPulseDot({
    super.key,
    required this.visible,
    this.color = AppColors.gold,
    this.size = 6,
  });

  final bool visible;
  final Color color;
  final double size;

  @override
  State<AnimatedPulseDot> createState() => _AnimatedPulseDotState();
}

class _AnimatedPulseDotState extends State<AnimatedPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.normal);
    _scale = _buildScale();
  }

  Animation<double> _buildScale() {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.65,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 1.0,
        ).chain(CurveTween(curve: AppMotion.standard)),
        weight: 45,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedPulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.visible && widget.visible) {
      _scale = _buildScale();
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
    if (!widget.visible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _controller.isAnimating ? _scale.value : 1.0,
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
