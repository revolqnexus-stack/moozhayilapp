import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';

/// Input variant: boxed (default) or underline (single-field screens).
enum InputVariant { boxed, underline }

/// Styled text input field.
/// Source: 02-design-system.md § Input System — Text Input
/// Source: 03-component-library.md § TextInput
class AppTextInput extends StatefulWidget {
  const AppTextInput({
    super.key,
    required this.placeholder,
    required this.value,
    required this.onChanged,
    this.label,
    this.onSubmit,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.variant = InputVariant.boxed,
    this.autofocus = false,
    this.textInputAction,
    this.controller,
    this.focusNode,
    this.inputFormatters,
  });

  final String placeholder;
  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final ValueChanged<String>? onSubmit;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final int? maxLength;
  final InputVariant variant;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  late FocusNode _focusNode;
  TextEditingController? _ownedController;
  bool _isFocused = false;

  TextEditingController get _effectiveController =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: widget.value);
    }
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the visible text in sync when parent resets value (e.g. after OTP send).
    if (widget.controller == null &&
        widget.value != oldWidget.value &&
        widget.value != _effectiveController.text) {
      _effectiveController.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.uiCaption.copyWith(color: AppColors.slateMist),
          ),
          const SizedBox(height: AppSpacing.xxs),
        ],
        _buildField(hasError),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            widget.errorText!,
            style: AppTypography.uiCaption.copyWith(color: AppColors.blushClay),
          ),
        ],
      ],
    );
  }

  Widget _buildField(bool hasError) {
    final borderColor = hasError
        ? AppColors.blushClay
        : _isFocused
        ? AppColors.textPrimary
        : AppColors.border;

    final inputDecoration = widget.variant == InputVariant.boxed
        ? _boxedDecoration(borderColor, hasError)
        : _underlineDecoration(borderColor, hasError);

    return TextField(
      controller: _effectiveController,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmit,
      obscureText: widget.isPassword,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      style: AppTypography.uiBodyMD.copyWith(color: AppColors.obsidian),
      decoration: inputDecoration,
    );
  }

  InputDecoration _boxedDecoration(Color borderColor, bool hasError) {
    return InputDecoration(
      hintText: widget.placeholder,
      hintStyle: AppTypography.uiBodyMD.copyWith(color: AppColors.slateMist),
      filled: true,
      fillColor: _isFocused
          ? AppColors.pureWhite
          : AppColors.warmIvory.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.gold, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      counterText: '',
    );
  }

  InputDecoration _underlineDecoration(Color borderColor, bool hasError) {
    return InputDecoration(
      hintText: widget.placeholder,
      hintStyle: AppTypography.uiBodyMD.copyWith(color: AppColors.slateMist),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      border: UnderlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: hasError ? AppColors.blushClay : AppColors.borderStrong,
          width: 0.5,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.blushClay, width: 1.5),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.blushClay, width: 1.5),
      ),
      counterText: '',
    );
  }
}
