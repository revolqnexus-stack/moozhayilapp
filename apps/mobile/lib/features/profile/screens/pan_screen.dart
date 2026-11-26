import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/text_input.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/customer_error_copy.dart';
import '../providers/kyc_provider.dart';

enum _PanUiState { idle, submitting, verified, notValid, nameMismatch, error }

class PanScreen extends ConsumerStatefulWidget {
  const PanScreen({super.key});

  @override
  ConsumerState<PanScreen> createState() => _PanScreenState();
}

class _PanScreenState extends ConsumerState<PanScreen> {
  static final _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  var _pan = '';
  var _name = '';
  var _state = _PanUiState.idle;
  var _maskPanField = false;
  String? _panError;
  String? _nameError;
  String? _statusMessage;

  Future<void> _verify() async {
    final pan = _pan.trim().toUpperCase();
    final name = _name.trim();
    String? panError;
    String? nameError;
    if (!_panPattern.hasMatch(pan)) {
      panError = 'Enter a valid PAN (e.g. ABCDE1234F)';
    }
    if (name.length > 256) {
      nameError = 'Name must be 256 characters or fewer';
    }
    if (panError != null || nameError != null) {
      setState(() {
        _state = _PanUiState.idle;
        _panError = panError;
        _nameError = nameError;
        _statusMessage = null;
      });
      return;
    }

    setState(() {
      _pan = pan;
      _name = name;
      _state = _PanUiState.submitting;
      _panError = null;
      _nameError = null;
      _statusMessage = null;
    });

    try {
      final result = await ref
          .read(kycFlowActionsProvider.notifier)
          .verifyPan(panNumber: pan, name: name);
      if (!mounted) return;

      if (!result.valid) {
        setState(() {
          _state = _PanUiState.notValid;
          _maskPanField = true;
          _statusMessage = 'PAN not valid';
        });
        return;
      }

      if (result.nameMismatch ||
          (name.isNotEmpty &&
              result.nameMatchResult != null &&
              result.nameMatchResult!.toUpperCase() != 'MATCH')) {
        setState(() {
          _state = _PanUiState.nameMismatch;
          _maskPanField = true;
          _statusMessage = 'Name does not match PAN records';
        });
        return;
      }

      setState(() {
        _state = _PanUiState.verified;
        _maskPanField = true;
        _statusMessage = 'PAN verified. Your KYC is complete.';
      });
    } catch (error) {
      if (!mounted) return;
      final fieldErrors = _fieldErrors(error);
      setState(() {
        _state = _PanUiState.error;
        _maskPanField = true;
        _panError = fieldErrors.$1;
        _nameError = fieldErrors.$2;
        _statusMessage = _customerMessage(error);
      });
    }
  }

  (String?, String?) _fieldErrors(Object error) {
    if (error is! ApiException) return (null, null);
    final fields = error.details?['fields'];
    if (fields is! Map) return (null, null);
    final pan = fields['pan'];
    final name = fields['name'];
    return (pan is String ? pan : null, name is String ? name : null);
  }

  String _customerMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return CustomerErrorCopy.message(error);
  }

  String get _visiblePan => _maskPanField ? _maskPan(_pan) : _pan;

  String _maskPan(String pan) {
    if (!_panPattern.hasMatch(pan)) return pan;
    return '${pan.substring(0, 5)}••••${pan.substring(9)}';
  }

  void _editPan() {
    setState(() {
      _state = _PanUiState.idle;
      _maskPanField = false;
      _statusMessage = null;
      _panError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final submitting = _state == _PanUiState.submitting;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppTopBar.detail(title: 'PAN Verification'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enter your PAN', style: AppTypography.headingMD),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Required for high-value transactions above ₹2,00,000 and enhanced verification.',
              style: AppTypography.uiBodySM.copyWith(
                color: AppColors.slateMist,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextInput(
              label: 'PAN number',
              placeholder: 'ABCDE1234F',
              value: _visiblePan,
              errorText: _panError,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toUpperCase());
                }),
              ],
              onChanged: submitting || _maskPanField
                  ? (_) {}
                  : (value) => setState(() {
                      _pan = value.toUpperCase();
                      _panError = null;
                    }),
            ),
            if (_maskPanField && !submitting)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _editPan,
                  child: const Text('Change PAN'),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            AppTextInput(
              label: 'Name on PAN (optional)',
              placeholder: 'Name as on the card',
              value: _name,
              errorText: _nameError,
              maxLength: 256,
              onChanged: submitting
                  ? (_) {}
                  : (value) => setState(() {
                      _name = value;
                      _nameError = null;
                      if (_state == _PanUiState.nameMismatch ||
                          _state == _PanUiState.notValid ||
                          _state == _PanUiState.error) {
                        _state = _PanUiState.idle;
                        _statusMessage = null;
                      }
                    }),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _statusMessage!,
                style: AppTypography.uiBodySM.copyWith(
                  color: _state == _PanUiState.verified
                      ? AppColors.successFill
                      : AppColors.errorFill,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _state == _PanUiState.verified
                  ? 'PAN verified'
                  : 'Verify PAN',
              isFullWidth: true,
              isLoading: submitting,
              isDisabled: _state == _PanUiState.verified,
              onTap: _verify,
            ),
            if (_state == _PanUiState.verified) ...[
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Continue',
                isFullWidth: true,
                // PAN verification now completes KYC; no selfie step.
                onTap: () => context.go(AppRoutes.profileKyc),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
