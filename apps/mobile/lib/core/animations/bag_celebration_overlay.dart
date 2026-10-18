import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/motion.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import '../utils/app_haptics.dart';

/// High-visibility “added to bag” burst — impossible to miss on PDP.
Future<void> showBagCelebrationOverlay(
  BuildContext context, {
  String message = 'Added to your bag',
}) async {
  if (!context.mounted) return;

  AppHaptics.medium();

  await showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: AppColors.ink.withValues(alpha: 0.35),
    transitionDuration: AppMotion.fast,
    pageBuilder: (dialogContext, _, _) {
      return _BagCelebrationDialog(message: message);
    },
    transitionBuilder: (_, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _BagCelebrationDialog extends StatefulWidget {
  const _BagCelebrationDialog({required this.message});

  final String message;

  @override
  State<_BagCelebrationDialog> createState() => _BagCelebrationDialogState();
}

class _BagCelebrationDialogState extends State<_BagCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ring;
  late final Animation<double> _check;
  late final Animation<double> _text;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _ring = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _check = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutBack),
    );
    _text = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );
    _ctrl.forward().then((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 520));
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          return Transform.scale(
            scale: 0.85 + (_ring.value * 0.15),
            child: Opacity(
              opacity: _text.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64 + (_ring.value * 20),
                            height: 64 + (_ring.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.gold.withValues(
                                  alpha: 0.35 + (_ring.value * 0.4),
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: _check.value,
                            child: Icon(
                              Icons.check_rounded,
                              size: 40,
                              color: AppColors.brandBurgundy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.message,
                      style: AppTypography.headingSM,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
