import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// Fancy / Nymira §2.6 — six-dot OTP entry with hidden numeric field.
class OtpDotField extends StatefulWidget {
  const OtpDotField({
    super.key,
    required this.value,
    required this.onChanged,
    this.length = 6,
    this.onCompleted,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final int length;
  final VoidCallback? onCompleted;

  @override
  State<OtpDotField> createState() => _OtpDotFieldState();
}

class _OtpDotFieldState extends State<OtpDotField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant OtpDotField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < widget.length; i++)
                _OtpDot(filled: i < widget.value.length),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpDot extends StatelessWidget {
  const _OtpDot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: AppSpacing.lg,
      height: AppSpacing.lg,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.maroon : AppColors.pureWhite,
        border: Border.all(
          color: filled ? AppColors.maroon : AppColors.smokeLine,
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
