import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/motion.dart';
import '../../core/utils/app_haptics.dart';

/// Animated Dream Vault heart button.
///
/// Save sequence (~280 ms): outline fills burgundy, gold sparkle pulse,
/// gentle scale 1.0 → 1.12 → 1.0, light haptic.
///
/// Unsave: heart gently un-fills with fade, very light haptic.
class VaultIconButton extends StatefulWidget {
  const VaultIconButton({
    super.key,
    required this.isInVault,
    required this.onTap,
    this.size = 22,
  });

  final bool isInVault;
  final VoidCallback? onTap;
  final double size;

  @override
  State<VaultIconButton> createState() => _VaultIconButtonState();
}

class _VaultIconButtonState extends State<VaultIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _sparkle;
  Animation<double>? _scaleOverride;
  var _unsaving = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: AppMotion.heartSave);

    _sparkle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(VaultIconButton old) {
    super.didUpdateWidget(old);
    if (!old.isInVault && widget.isInVault) {
      _playHeartSave();
    } else if (old.isInVault && !widget.isInVault) {
      _playHeartUnsave();
    }
  }

  void _playHeartSave() {
    AppHaptics.light();
    _unsaving = false;

    final scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.12,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
    ]).animate(_ctrl);

    _ctrl.reset();
    _scaleOverride = scaleAnim;
    _ctrl.forward().then((_) {
      if (mounted) setState(() => _scaleOverride = null);
    });
  }

  void _playHeartUnsave() {
    AppHaptics.light();
    setState(() => _unsaving = true);
    _ctrl.reset();
    Future<void>.delayed(AppMotion.normal, () {
      if (mounted) setState(() => _unsaving = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.isInVault
          ? 'Remove from Dream Vault'
          : 'Save to Dream Vault',
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final scale = _scaleOverride?.value ?? 1.0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_ctrl.isAnimating && widget.isInVault)
                      Opacity(
                        opacity: _sparkle.value,
                        child: Container(
                          width: widget.size + 14,
                          height: widget.size + 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withValues(
                                alpha: _sparkle.value * 0.55,
                              ),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    Transform.scale(
                      scale: scale,
                      child: AnimatedSwitcher(
                        duration: _unsaving
                            ? AppMotion.normal
                            : AppMotion.vaultIconSwap,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.92, end: 1).animate(
                              CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: child,
                          ),
                        ),
                        child: Icon(
                          widget.isInVault
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(widget.isInVault),
                          color: widget.isInVault
                              ? AppColors.brandBurgundy
                              : AppColors.slateMist,
                          size: widget.size,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
