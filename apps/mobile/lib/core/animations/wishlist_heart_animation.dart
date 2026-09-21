import 'package:flutter/material.dart';
import '../constants/animations.dart';
import '../constants/colors.dart';

/// Premium wishlist heart animation: heart fills with molten gold effect.
/// Used when adding/removing products from Dream Vault.
class WishlistHeartAnimation extends StatefulWidget {
  const WishlistHeartAnimation({
    super.key,
    required this.isLiked,
    this.size = 24,
    this.onTap,
  });

  final bool isLiked;
  final double size;
  final VoidCallback? onTap;

  @override
  State<WishlistHeartAnimation> createState() => _WishlistHeartAnimationState();
}

class _WishlistHeartAnimationState extends State<WishlistHeartAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fillProgress;
  late final Animation<double> _scale;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.wishlistAdd,
    );

    _fillProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic),
      ),
    );

    _scale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.2),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.2, end: 1.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        );

    _shimmer = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isLiked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(WishlistHeartAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      if (widget.isLiked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _HeartPainter(
                  fillProgress: _fillProgress.value,
                  shimmerProgress: _shimmer.value,
                  isLiked: widget.isLiked,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({
    required this.fillProgress,
    required this.shimmerProgress,
    required this.isLiked,
  });

  final double fillProgress;
  final double shimmerProgress;
  final bool isLiked;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHeartPath(size);

    // Outline
    final outlinePaint = Paint()
      ..color = isLiked ? AppColors.gold : AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, outlinePaint);

    // Molten gold fill
    if (fillProgress > 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(
          0,
          size.height * (1 - fillProgress),
          size.width,
          size.height * fillProgress,
        ),
      );

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.goldLight.withValues(alpha: 0.8), AppColors.gold],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, fillPaint);

      // Shimmer highlight
      if (shimmerProgress > 0) {
        final shimmerPaint = Paint()
          ..color = AppColors.cream.withValues(alpha: 0.4 * shimmerProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        final shimmerY =
            size.height * (1 - fillProgress) +
            (size.height * fillProgress * shimmerProgress);

        canvas.drawRect(
          Rect.fromLTWH(0, shimmerY - 2, size.width, 4),
          shimmerPaint,
        );
      }

      canvas.restore();
    }
  }

  Path _createHeartPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h * 0.3);
    path.cubicTo(w / 2, h * 0.15, w * 0.3, h * 0.05, w * 0.15, h * 0.15);
    path.cubicTo(0, h * 0.3, 0, h * 0.5, w * 0.15, h * 0.7);
    path.lineTo(w / 2, h * 0.95);
    path.lineTo(w * 0.85, h * 0.7);
    path.cubicTo(w, h * 0.5, w, h * 0.3, w * 0.85, h * 0.15);
    path.cubicTo(w * 0.7, h * 0.05, w / 2, h * 0.15, w / 2, h * 0.3);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) =>
      oldDelegate.fillProgress != fillProgress ||
      oldDelegate.shimmerProgress != shimmerProgress;
}
