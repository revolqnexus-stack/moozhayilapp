import 'package:flutter/material.dart';
import '../constants/animations.dart';
import '../constants/colors.dart';

/// Premium KYC verified seal animation: identity card receives gold verified seal.
/// Seal stamps down with slight bounce, then glows briefly.
class KycVerifiedSeal extends StatefulWidget {
  const KycVerifiedSeal({super.key, this.size = 100, this.onComplete});

  final double size;
  final VoidCallback? onComplete;

  @override
  State<KycVerifiedSeal> createState() => _KycVerifiedSealState();
}

class _KycVerifiedSealState extends State<KycVerifiedSeal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _stampDown;
  late final Animation<double> _stampBounce;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.kycApproved,
    );

    // Stamp descends (0-30%)
    _stampDown = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInQuart),
      ),
    );

    // Subtle bounce (30-50%)
    _stampBounce =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.9),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.9, end: 1.05),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.05, end: 1.0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
          ),
        );

    // Glow effect (50-100%)
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
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
        return Transform.translate(
          offset: Offset(0, _stampDown.value),
          child: Transform.scale(
            scale: _stampBounce.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.gold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4 * _glow.value),
                    blurRadius: 20 * _glow.value,
                    spreadRadius: 4 * _glow.value,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified,
                    size: widget.size * 0.4,
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'VERIFIED',
                    style: TextStyle(
                      fontSize: widget.size * 0.12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                      letterSpacing: widget.size * 0.02,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
