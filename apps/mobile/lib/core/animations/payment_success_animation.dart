import 'package:flutter/material.dart';
import '../constants/animations.dart';
import '../constants/colors.dart';

/// Premium payment success animation: gold tick draws itself inside a circular seal.
/// Used after successful payment (schemes, orders, manual contributions).
class PaymentSuccessAnimation extends StatefulWidget {
  const PaymentSuccessAnimation({super.key, this.size = 120, this.onComplete});

  final double size;
  final VoidCallback? onComplete;

  @override
  State<PaymentSuccessAnimation> createState() =>
      _PaymentSuccessAnimationState();
}

class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sealScale;
  late final Animation<double> _tickProgress;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.paymentSuccess,
    );

    // Seal appears first
    _sealScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutQuart),
      ),
    );

    // Tick draws from 40% to 80%
    _tickProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // Subtle gold shimmer at the end
    _shimmer = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => widget.onComplete?.call());
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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer seal circle
              Transform.scale(
                scale: _sealScale.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(
                          alpha: 0.3 * _shimmer.value,
                        ),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Tick path drawing
              CustomPaint(
                size: Size(widget.size * 0.5, widget.size * 0.5),
                painter: _TickPainter(
                  progress: _tickProgress.value,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Tick shape: short stroke down-left, then long stroke up-right
    final p1 = Offset(size.width * 0.2, size.height * 0.5);
    final p2 = Offset(size.width * 0.4, size.height * 0.7);
    final p3 = Offset(size.width * 0.8, size.height * 0.3);

    if (progress <= 0.4) {
      // Draw first stroke (p1 → p2)
      final t = progress / 0.4;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      // First stroke complete
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);

      // Draw second stroke (p2 → p3)
      final t = (progress - 0.4) / 0.6;
      path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TickPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
