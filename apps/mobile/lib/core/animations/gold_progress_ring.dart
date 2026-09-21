import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/animations.dart';
import '../constants/colors.dart';

/// Premium circular gold progress ring that fills smoothly.
/// Used for goal progress, scheme maturity, KYC completion.
class GoldProgressRing extends StatefulWidget {
  const GoldProgressRing({
    super.key,
    required this.percent,
    this.size = 120,
    this.strokeWidth = 8,
    this.animateOnMount = true,
    this.showPercentage = true,
    this.centerWidget,
  });

  final double percent; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final bool animateOnMount;
  final bool showPercentage;
  final Widget? centerWidget;

  @override
  State<GoldProgressRing> createState() => _GoldProgressRingState();
}

class _GoldProgressRingState extends State<GoldProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.goalProgressFill,
    );

    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.percent.clamp(0.0, 1.0)).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AnimationPresets.goalProgressCurve,
          ),
        );

    if (widget.animateOnMount) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GoldProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _progressAnimation =
          Tween<double>(
            begin: oldWidget.percent.clamp(0.0, 1.0),
            end: widget.percent.clamp(0.0, 1.0),
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: AnimationPresets.goalProgressCurve,
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
      animation: _progressAnimation,
      builder: (context, child) {
        final displayPercent = (_progressAnimation.value * 100).round();
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring (pearl/ivory)
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  color: AppColors.pearl,
                  strokeWidth: widget.strokeWidth,
                ),
              ),

              // Gold progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _progressAnimation.value,
                  color: AppColors.gold,
                  strokeWidth: widget.strokeWidth,
                ),
              ),

              // Center content
              if (widget.centerWidget != null)
                widget.centerWidget!
              else if (widget.showPercentage)
                Text(
                  '$displayPercent%',
                  style: TextStyle(
                    fontSize: widget.size * 0.2,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.02,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Start from top (-90 degrees), draw clockwise
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
