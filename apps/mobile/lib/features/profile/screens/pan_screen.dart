import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/text_input.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/kyc_status.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/pan_mask.dart';
import '../providers/kyc_provider.dart';

enum _PanUiState { idle, submitting, verified, notValid, nameMismatch, error }

class PanScreen extends ConsumerStatefulWidget {
  const PanScreen({super.key});

  @override
  ConsumerState<PanScreen> createState() => _PanScreenState();
}

class _PanScreenState extends ConsumerState<PanScreen> {
  var _pan = '';
  var _name = '';
  String? _errorMessage;
  _PanUiState _uiState = _PanUiState.idle;
  String? _maskedPan;
  PanVerifyResponse? _lastResult;

  bool get _loading => _uiState == _PanUiState.submitting;

  Future<void> _verify() async {
    final value = _pan.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(value)) {
      setState(() {
        _uiState = _PanUiState.error;
        _errorMessage = 'Enter a valid PAN (e.g. ABCDE1234F)';
      });
      return;
    }

    final trimmedName = _name.trim();

    setState(() {
      _uiState = _PanUiState.submitting;
      _errorMessage = null;
      _lastResult = null;
    });

    try {
      final result = await ref
          .read(kycFlowActionsProvider.notifier)
          .verifyPan(value, name: trimmedName.isEmpty ? null : trimmedName);

      if (!mounted) {
        return;
      }

      setState(() {
        _maskedPan = maskPan(value);
        _lastResult = result;
      });

      if (result.verified) {
        setState(() => _uiState = _PanUiState.verified);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.push(AppRoutes.profileKycBank);
        }
        return;
      }

      if (result.isNameMismatch) {
        setState(() => _uiState = _PanUiState.nameMismatch);
        return;
      }

      setState(() => _uiState = _PanUiState.notValid);
    } catch (error) {
      setState(() {
        _uiState = _PanUiState.error;
        _errorMessage = CustomerErrorCopy.message(error);
      });
    }
  }

  String? _statusLine() {
    return switch (_uiState) {
      _PanUiState.verified => 'PAN verified successfully.',
      _PanUiState.notValid =>
        _lastResult?.message ??
            'PAN not valid. Check the number and try again.',
      _PanUiState.nameMismatch => 'Name does not match PAN records.',
      _ => null,
    };
  }

  Color _statusColor() {
    return switch (_uiState) {
      _PanUiState.verified => AppColors.successFill,
      _PanUiState.notValid ||
      _PanUiState.nameMismatch => AppColors.burgundyDeep,
      _ => AppColors.slateMist,
    };
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(kycStatusProvider);
    final statusLine = _statusLine();

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
              value: _maskedPan ?? _pan,
              errorText: _uiState == _PanUiState.error ? _errorMessage : null,
              onChanged: (value) {
                if (_maskedPan != null) {
                  return;
                }
                setState(() {
                  _pan = value.toUpperCase();
                  if (_uiState == _PanUiState.error) {
                    _uiState = _PanUiState.idle;
                    _errorMessage = null;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextInput(
              label: 'Name on PAN (optional)',
              placeholder: 'As on your PAN card',
              value: _name,
              onChanged: (value) => setState(() {
                _name = value;
                if (_uiState == _PanUiState.nameMismatch) {
                  _uiState = _PanUiState.idle;
                }
              }),
            ),
            if (statusLine != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                statusLine,
                style: AppTypography.uiBodySM.copyWith(color: _statusColor()),
              ),
            ],
            if (_lastResult?.nameOnPanMasked != null &&
                _uiState == _PanUiState.nameMismatch) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Registered name: ${_lastResult!.nameOnPanMasked}',
                style: AppTypography.uiBodySM.copyWith(
                  color: AppColors.slateMist,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _uiState == _PanUiState.nameMismatch
                  ? 'Try again'
                  : 'Verify PAN',
              isFullWidth: true,
              isLoading: _loading,
              onTap: _loading ? null : _verify,
            ),
            const SizedBox(height: AppSpacing.sm),
            status.when(
              data: (kyc) {
                if (kyc.aadhaarVerified) {
                  return PrimaryButton(
                    label: 'Skip to selfie',
                    isFullWidth: true,
                    onTap: () => context.push(AppRoutes.profileKycSelfie),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
