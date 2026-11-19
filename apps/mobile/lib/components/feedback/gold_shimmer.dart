import 'package:flutter/material.dart';

import '../../core/constants/animations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';

/// Premium gold-gradient shimmer for content loading.
///
/// Replaces the neutral grey shimmer with a warm gold sweep that
/// references hallmarked 22KT catching light. Reserved for product cards,
/// scheme panels, and catalogue grids — never for blocking payment states.
class GoldShimmer extends StatefulWidget {
  const GoldShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.card,
  });

  const GoldShimmer.full({
    super.key,
    required this.height,
    this.borderRadius = AppRadius.card,
  }) : width = double.infinity;

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<GoldShimmer> createState() => _GoldShimmerState();
}

class _GoldShimmerState extends State<GoldShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.goldShimmer,
    )..repeat();
    _animation = _controller;
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
      builder: (context, _) {
        final offset = _animation.value * 3 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(offset - 1, 0),
              end: Alignment(offset + 1, 0),
              colors: const [
                AppColors.shimmerBase,
                AppColors.goldTrace,
                AppColors.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
