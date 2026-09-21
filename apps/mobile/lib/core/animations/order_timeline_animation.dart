import 'package:flutter/material.dart';
import '../constants/animations.dart';
import '../constants/colors.dart';

/// Premium order tracking timeline with animated progress.
/// Shows: Confirmed → Packed → Shipped → Out for delivery → Delivered
class OrderTimelineAnimation extends StatefulWidget {
  const OrderTimelineAnimation({
    super.key,
    required this.steps,
    required this.currentStep,
    this.animate = true,
  });

  final List<OrderTimelineStep> steps;
  final int currentStep; // 0-indexed
  final bool animate;

  @override
  State<OrderTimelineAnimation> createState() => _OrderTimelineAnimationState();
}

class _OrderTimelineAnimationState extends State<OrderTimelineAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppAnimations.xl);

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(OrderTimelineAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
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
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            for (var i = 0; i < widget.steps.length; i++) ...[
              _TimelineStepWidget(
                step: widget.steps[i],
                isCompleted: i < widget.currentStep,
                isCurrent: i == widget.currentStep,
                progress: i == widget.currentStep ? _controller.value : 1.0,
              ),
              if (i < widget.steps.length - 1)
                _TimelineConnector(
                  isCompleted: i < widget.currentStep,
                  progress: i < widget.currentStep - 1
                      ? 1.0
                      : _controller.value,
                ),
            ],
          ],
        );
      },
    );
  }
}

class OrderTimelineStep {
  const OrderTimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _TimelineStepWidget extends StatelessWidget {
  const _TimelineStepWidget({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
    required this.progress,
  });

  final OrderTimelineStep step;
  final bool isCompleted;
  final bool isCurrent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isCurrent ? AppColors.gold : AppColors.pearl;
    final textColor = isCompleted || isCurrent
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon circle
        AnimatedContainer(
          duration: AppAnimations.md,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(step.icon, size: 24, color: color),
        ),

        const SizedBox(width: 16),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  letterSpacing: 0.02,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.subtitle,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.isCompleted, required this.progress});

  final bool isCompleted;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 23),
      child: SizedBox(
        width: 2,
        height: 32,
        child: CustomPaint(
          painter: _ConnectorPainter(
            progress: progress,
            color: isCompleted ? AppColors.gold : AppColors.pearl,
          ),
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
