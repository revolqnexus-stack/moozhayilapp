import 'package:flutter/material.dart';
import '../constants/animations.dart';
import '../constants/colors.dart';
import 'dart:math' as math;

/// Premium payment processing animation: rotating gold ring with subtle shimmer.
/// Shows while payment is being verified by Razorpay.
class PaymentProcessingAnimation extends StatefulWidget {
  const PaymentProcessingAnimation({super.key, this.size = 80});

  final double size;

  @override
  State<PaymentProcessingAnimation> createState() =>
      _PaymentProcessingAnimationState();
}

class _PaymentProcessingAnimationState extends State<PaymentProcessingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.paymentProcessing,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _GoldRingPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _GoldRingPainter extends CustomPainter {
  _GoldRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Gold ring with gradient
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.3),
          AppColors.gold,
          AppColors.goldLight,
          AppColors.gold,
          AppColors.gold.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw rotating arc (3/4 circle)
    const startAngle = -math.pi / 2;
    const sweepAngle = 1.5 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + (progress * 2 * math.pi),
      sweepAngle,
      false,
      paint,
    );

    // Shimmer effect at leading edge
    final shimmerPaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final shimmerAngle = startAngle + (progress * 2 * math.pi) + sweepAngle;
    final shimmerX = center.dx + radius * math.cos(shimmerAngle);
    final shimmerY = center.dy + radius * math.sin(shimmerAngle);

    canvas.drawCircle(Offset(shimmerX, shimmerY), 4, shimmerPaint);
  }

  @override
  bool shouldRepaint(_GoldRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
