import 'package:flutter/material.dart';

import '../constants/animations.dart';
import '../constants/colors.dart';
import '../utils/indian_format.dart';

/// Premium vault opening animation: vault opens to reveal accumulated gold.
/// Used when scheme matures or goal completes.
class VaultOpeningAnimation extends StatefulWidget {
  const VaultOpeningAnimation({
    super.key,
    required this.goldGrams,
    this.size = 200,
    this.onComplete,
  });

  final double goldGrams;
  final double size;
  final VoidCallback? onComplete;

  @override
  State<VaultOpeningAnimation> createState() => _VaultOpeningAnimationState();
}

class _VaultOpeningAnimationState extends State<VaultOpeningAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _doorOpen;
  late final Animation<double> _goldReveal;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.schemeMature,
    );

    // Vault door opens (0-40%)
    _doorOpen = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOutQuart),
      ),
    );

    // Gold content reveals (30-70%)
    _goldReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Shine effect (60-100%)
    _shine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
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
              // Vault body
              Container(
                width: widget.size * 0.8,
                height: widget.size * 0.8,
                decoration: BoxDecoration(
                  color: AppColors.brandBurgundy,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),

              // Vault door (opens to the right)
              Positioned(
                right: widget.size * 0.1,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_doorOpen.value * 1.2),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: widget.size * 0.4,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      color: AppColors.brandBurgundy,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_outline,
                        size: widget.size * 0.15,
                        color: AppColors.gold.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Gold content revealed
              if (_goldReveal.value > 0)
                Opacity(
                  opacity: _goldReveal.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: widget.size * 0.2,
                        color: AppColors.gold,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        IndianFormat.formatGramsDouble(widget.goldGrams),
                        style: TextStyle(
                          fontSize: widget.size * 0.12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gold,
                          letterSpacing: 0.04,
                        ),
                      ),
                      Text(
                        'GOLD',
                        style: TextStyle(
                          fontSize: widget.size * 0.08,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gold.withValues(alpha: 0.7),
                          letterSpacing: 0.12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Shine effect
              if (_shine.value > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ShinePainter(progress: _shine.value),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShinePainter extends CustomPainter {
  _ShinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          AppColors.goldLight.withValues(alpha: 0.3 * (1 - progress)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..blendMode = BlendMode.plus;

    final path = Path()
      ..moveTo(size.width * (progress - 0.1), 0)
      ..lineTo(size.width * progress, 0)
      ..lineTo(size.width * (progress + 0.1), size.height)
      ..lineTo(size.width * progress, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Product shrinks into glowing vault card animation.
class ShrinkToVaultAnimation extends StatefulWidget {
  const ShrinkToVaultAnimation({
    super.key,
    required this.child,
    required this.onComplete,
  });

  final Widget child;
  final VoidCallback onComplete;

  @override
  State<ShrinkToVaultAnimation> createState() => _ShrinkToVaultAnimationState();
}

class _ShrinkToVaultAnimationState extends State<ShrinkToVaultAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fadeOut;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.vaultAdd,
    );

    _scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationPresets.vaultAddCurve,
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
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
        return Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _fadeOut.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4 * _glow.value),
                    blurRadius: 20 * _glow.value,
                    spreadRadius: 4 * _glow.value,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
