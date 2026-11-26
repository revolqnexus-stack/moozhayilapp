import 'package:flutter/material.dart';

import '../../core/constants/motion.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';

/// Animated linear progress bar.
/// Source: 02-design-system.md § Progress Components
/// Source: 03-component-library.md § LinearProgressBar
///
/// On first mount the fill animates from 0 → [percent] (600 ms, easeOut).
/// When [percent] changes the bar smoothly transitions to the new value.
class LinearProgressBar extends StatefulWidget {
  const LinearProgressBar({
    super.key,
    required this.percent,
    this.height = 8,
    this.trackColor = AppColors.smokeLine,
    this.progressColor = AppColors.antiqueGold,
  });

  final int percent;
  final double height;
  final Color trackColor;
  final Color progressColor;

  @override
  State<LinearProgressBar> createState() => _LinearProgressBarState();
}

class _LinearProgressBarState extends State<LinearProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppMotion.progressFill);
    _fill = Tween<double>(
      begin: 0,
      end: widget.percent.clamp(0, 100) / 100.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(LinearProgressBar old) {
    super.didUpdateWidget(old);
    if (old.percent != widget.percent) {
      final from = _fill.value;
      _fill = Tween<double>(
        begin: from,
        end: widget.percent.clamp(0, 100) / 100.0,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
      animation: _fill,
      builder: (_, _) => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: widget.trackColor),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _fill.value,
                child: ColoredBox(color: widget.progressColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
