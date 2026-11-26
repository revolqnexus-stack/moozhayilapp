import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/motion.dart';
import '../../core/constants/colors.dart';

/// Animated circular progress ring.
/// Source: 02-design-system.md § Progress Components
/// Source: 03-component-library.md § ProgressRing
///
/// Rule 10 (09-cursor-rules.md): uses [AppMotion.progressFill] +
/// [AppMotion.standardInOut].
///
/// On first mount the arc animates from 0 → [percent] (800 ms).
/// On [percent] change the arc transitions smoothly.
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 72,
    this.strokeWidth = 6,
    this.center,
    this.trackColor = AppColors.smokeLine,
    this.progressColor = AppColors.antiqueGold,
  });

  final int percent;
  final double size;
  final double strokeWidth;
  final Widget? center;
  final Color trackColor;
  final Color progressColor;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppMotion.progressFill);
    _progress = Tween<double>(
      begin: 0,
      end: widget.percent.clamp(0, 100) / 100.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.standardInOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ProgressRing old) {
    super.didUpdateWidget(old);
    if (old.percent != widget.percent) {
      final from = _progress.value;
      _progress = Tween<double>(
        begin: from,
        end: widget.percent.clamp(0, 100) / 100.0,
      ).animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.standardInOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, _) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(widget.size),
              painter: _RingPainter(
                progress: _progress.value,
                strokeWidth: widget.strokeWidth,
                trackColor: widget.trackColor,
                progressColor: widget.progressColor,
              ),
            ),
            widget.center ??
                Text(
                  '${widget.percent.clamp(0, 100)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.obsidian,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  /// Animated progress value in [0, 1].
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
