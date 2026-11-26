import 'package:flutter/material.dart';
import '../../core/constants/motion.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';

/// Shimmer loading placeholder.
/// Source: 02-design-system.md § Shimmer / Skeleton System
/// Source: 03-component-library.md § LoadingShimmer
///
/// Renders a gradient-animated placeholder rectangle that exactly matches
/// the dimensions and border radius of the content it replaces.
///
/// Animation: left-to-right sweep, 1200ms loop.
/// Gradient: [AppColors.shimmerBase] → [AppColors.shimmerHighlight] → [AppColors.shimmerBase].
///
/// Rule 5 (09-cursor-rules.md): Use shimmer for content loading.
/// Spinners are reserved for button-loading and blocking payment states only.
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.card,
  });

  /// Convenience constructor for a full-width shimmer.
  const LoadingShimmer.full({
    super.key,
    required this.height,
    this.borderRadius = AppRadius.card,
  }) : width = double.infinity;

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.shimmerCycle,
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
        // The gradient translate value moves from -1 (off-screen left)
        // to +1 (off-screen right) across the full animation duration.
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
                AppColors.shimmerHighlight,
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
