import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/animations.dart';
import '../constants/colors.dart';

/// Premium Aura thinking animation: elegant flowing gold line (not bouncing dots).
/// Shows while Aura is processing the user's request.
class AuraThinkingAnimation extends StatefulWidget {
  const AuraThinkingAnimation({super.key, this.width = 120, this.height = 40});

  final double width;
  final double height;

  @override
  State<AuraThinkingAnimation> createState() => _AuraThinkingAnimationState();
}

class _AuraThinkingAnimationState extends State<AuraThinkingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.auraThinking,
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
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _FlowingLinePainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _FlowingLinePainter extends CustomPainter {
  _FlowingLinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.3),
          AppColors.gold,
          AppColors.goldLight,
          AppColors.gold.withValues(alpha: 0.3),
        ],
        stops: [
          0.0,
          math.max(0.0, progress - 0.3),
          progress,
          math.min(1.0, progress + 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw elegant sine wave
    final path = Path();
    const waveCount = 1.5;
    const amplitude = 10.0;

    path.moveTo(0, size.height / 2);

    for (var x = 0.0; x <= size.width; x += 2.0) {
      final normalizedX = x / size.width;
      final y =
          size.height / 2 +
          amplitude *
              math.sin(
                (normalizedX * waveCount * 2 * math.pi) +
                    (progress * 2 * math.pi),
              );
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FlowingLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Alternative: Aura typing indicator with ink-writing effect.
class AuraTypingAnimation extends StatefulWidget {
  const AuraTypingAnimation({super.key, this.dotSize = 8});

  final double dotSize;

  @override
  State<AuraTypingAnimation> createState() => _AuraTypingAnimationState();
}

class _AuraTypingAnimationState extends State<AuraTypingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypingDot(controller: _controller, delay: 0.0, size: widget.dotSize),
        SizedBox(width: widget.dotSize * 0.8),
        _TypingDot(controller: _controller, delay: 0.15, size: widget.dotSize),
        SizedBox(width: widget.dotSize * 0.8),
        _TypingDot(controller: _controller, delay: 0.3, size: widget.dotSize),
      ],
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({
    required this.controller,
    required this.delay,
    required this.size,
  });

  final AnimationController controller;
  final double delay;
  final double size;

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(
                    alpha: 0.3 * animation.value,
                  ),
                  blurRadius: 4 * animation.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
