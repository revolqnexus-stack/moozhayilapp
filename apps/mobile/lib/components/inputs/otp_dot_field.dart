import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/motion.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../core/utils/motion_preferences.dart';

/// Fancy / Nymira §2.6 — six-dot OTP entry with hidden numeric field.
///
/// When [hasError] turns true (e.g. the server rejected the code) the dots
/// switch to the error colour and the row gives one small horizontal shake.
/// The shake is skipped when reduced motion is on.
class OtpDotField extends StatefulWidget {
  const OtpDotField({
    super.key,
    required this.value,
    required this.onChanged,
    this.length = 6,
    this.onCompleted,
    this.hasError = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final int length;
  final VoidCallback? onCompleted;

  /// Shows the error state; each false → true change triggers one shake.
  final bool hasError;

  @override
  State<OtpDotField> createState() => _OtpDotFieldState();
}

class _OtpDotFieldState extends State<OtpDotField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _shake;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _shake = AnimationController(vsync: this, duration: AppMotion.errorShake);
    // Damped oscillation, max 6 px: noticeable without feeling jittery.
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shake, curve: AppMotion.decelerate));
  }

  @override
  void didUpdateWidget(covariant OtpDotField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
    if (widget.hasError && !oldWidget.hasError) {
      AppHaptics.medium();
      if (premiumMotionEnabled(context)) _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _handleChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > widget.length
        ? digits.substring(0, widget.length)
        : digits;
    if (clipped != _controller.text) {
      _controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
    }
    widget.onChanged(clipped);
    if (clipped.length == widget.length) {
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 1, color: Colors.transparent),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _handleChanged,
            ),
          ),
          AnimatedBuilder(
            animation: _shakeOffset,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shakeOffset.value, 0),
              child: child,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < widget.length; i++)
                  _OtpDot(
                    filled: i < widget.value.length,
                    hasError: widget.hasError,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpDot extends StatelessWidget {
  const _OtpDot({required this.filled, required this.hasError});

  final bool filled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final fill = hasError ? AppColors.errorFill : AppColors.maroon;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: AppSpacing.lg,
      height: AppSpacing.lg,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? fill : AppColors.pureWhite,
        border: Border.all(
          color: hasError || filled ? fill : AppColors.smokeLine,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: filled
          ? Text(
              '•',
              style: AppTypography.uiBodySM.copyWith(
                color: AppColors.pureWhite,
              ),
            )
          : null,
    );
  }
}
