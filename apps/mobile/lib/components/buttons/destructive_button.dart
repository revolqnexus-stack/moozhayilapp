import 'package:flutter/material.dart';
import '../../core/constants/motion.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// Destructive (outlined danger) button.
/// Source: 02-design-system.md § Button System — Destructive Button
///
/// Same structure as [SecondaryButton] but uses [AppColors.blushClay]
/// for border and text. Used for "Sign Out", "Remove from Vault", etc.
/// Deliberately uses blush clay (not alarming red) to stay calm and premium.
class DestructiveButton extends StatefulWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  State<DestructiveButton> createState() => _DestructiveButtonState();
}

class _DestructiveButtonState extends State<DestructiveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: AnimatedContainer(
        duration: AppMotion.buttonStateChange,
        height: 48,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.errorFill : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: AppColors.blushClay, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(
                child: Text(
                  widget.label,
                  style: AppTypography.buttonLabel.copyWith(
                    color: AppColors.blushClay,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
