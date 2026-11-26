import 'package:flutter/material.dart';
import '../../core/constants/motion.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// Secondary (outlined) button.
/// Source: 02-design-system.md § Button System — Secondary Button
/// Source: 03-component-library.md § SecondaryButton
///
/// States: default | pressed (bg champagneVeil) | disabled | loading.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  bool get _isInteractive => !widget.isDisabled && !widget.isLoading;
  Color get _borderColor =>
      _isInteractive ? AppColors.borderStrong : AppColors.border;
  Color get _textColor =>
      _isInteractive ? AppColors.textPrimary : AppColors.disabledText;
  Color get _bgColor => _pressed ? AppColors.bgWhite : Colors.transparent;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.buttonPress,
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
    if (!_isInteractive) return;
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
    final button = Semantics(
      button: true,
      enabled: _isInteractive,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: AppMotion.buttonStateChange,
          height: 48,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: _borderColor, width: 0.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isInteractive ? widget.onTap : null,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: BorderRadius.circular(AppRadius.button),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _textColor,
                            ),
                          ),
                        )
                      : Text(
                          widget.label,
                          style: AppTypography.buttonLabel.copyWith(
                            color: _textColor,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return widget.isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
