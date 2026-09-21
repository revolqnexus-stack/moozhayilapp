import 'package:flutter/material.dart';
import '../../core/constants/animations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// Primary call-to-action button.
/// Source: 02-design-system.md § Button System — Primary Button
/// Source: 03-component-library.md § PrimaryButton
///
/// States: default | pressed | disabled | loading.
/// Loading state shows a [CircularProgressIndicator], not a spinner,
/// as the button is blocking (per Rule 5 comment in 09-cursor-rules.md).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.iconLeft,
    this.iconRight,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final IconData? iconLeft;
  final IconData? iconRight;

  bool get _isInteractive => !isDisabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final button = _ButtonBody(
      onTap: _isInteractive ? onTap : null,
      backgroundColor: _isInteractive ? AppColors.ink : AppColors.disabledBg,
      child: isLoading ? _loadingChild : _labelChild,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget get _loadingChild => const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.cream),
    ),
  );

  Widget get _labelChild => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (iconLeft != null) ...[
        Icon(
          iconLeft,
          size: 18,
          color: _isInteractive ? AppColors.cream : AppColors.disabledText,
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
      Text(
        label,
        style: AppTypography.buttonLabel.copyWith(
          color: _isInteractive ? AppColors.cream : AppColors.disabledText,
          letterSpacing: 0.06,
          fontWeight: FontWeight.w500,
        ),
      ),
      if (iconRight != null) ...[
        const SizedBox(width: AppSpacing.xs),
        Icon(
          iconRight,
          size: 18,
          color: _isInteractive ? AppColors.cream : AppColors.disabledText,
        ),
      ],
    ],
  );
}

// ── Shared private button scaffold ───────────────────────────────────────────

class _ButtonBody extends StatefulWidget {
  const _ButtonBody({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  final VoidCallback? onTap;
  final Color backgroundColor;
  final Widget child;

  @override
  State<_ButtonBody> createState() => _ButtonBodyState();
}

class _ButtonBodyState extends State<_ButtonBody>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: AppAnimations.buttonPress,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    _scaleCtrl.forward();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    _scaleCtrl.reverse();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _scaleCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _pressed ? AppColors.brandBurgundy : widget.backgroundColor;

    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: AppAnimations.xs,
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: widget.onTap != null
                  ? AppColors.gold.withValues(alpha: 0.35)
                  : AppColors.borderStrong,
              width: widget.onTap != null ? 0.5 : 1,
            ),
            boxShadow: widget.onTap != null
                ? [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: BorderRadius.circular(AppRadius.button),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
