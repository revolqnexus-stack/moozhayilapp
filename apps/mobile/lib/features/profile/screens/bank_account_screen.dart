import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/text_input.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/kyc_status.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/account_mask.dart';
import '../providers/kyc_provider.dart';

enum _BankUiState {
  idle,
  submitting,
  verified,
  notVerified,
  nameMismatch,
  error,
}

class BankAccountScreen extends ConsumerStatefulWidget {
  const BankAccountScreen({super.key});

  @override
  ConsumerState<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends ConsumerState<BankAccountScreen> {
  var _accountNumber = '';
  var _ifsc = '';
  var _name = '';
  String? _errorMessage;
  _BankUiState _uiState = _BankUiState.idle;
  String? _maskedAccount;
  BankVerifyResponse? _lastResult;

  bool get _loading => _uiState == _BankUiState.submitting;

  Future<void> _verify() async {
    final accountDigits = _accountNumber.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{9,18}$').hasMatch(accountDigits)) {
      setState(() {
        _uiState = _BankUiState.error;
        _errorMessage = 'Account number must be 9 to 18 digits';
      });
      return;
    }

    final ifsc = _ifsc.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
      setState(() {
        _uiState = _BankUiState.error;
        _errorMessage = 'Enter a valid IFSC (e.g. ICIC0001234)';
      });
      return;
    }

    final trimmedName = _name.trim();

    setState(() {
      _uiState = _BankUiState.submitting;
      _errorMessage = null;
      _lastResult = null;
    });

    try {
      final result = await ref
          .read(kycFlowActionsProvider.notifier)
          .verifyBankAccount(
            accountDigits,
            ifsc: ifsc,
            name: trimmedName.isEmpty ? null : trimmedName,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _maskedAccount = maskBankAccount(accountDigits);
        _lastResult = result;
      });

      if (result.verified) {
        setState(() => _uiState = _BankUiState.verified);
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.push(AppRoutes.profileKycSelfie);
        }
        return;
      }

      if (result.isNameMismatch) {
        setState(() => _uiState = _BankUiState.nameMismatch);
        return;
      }

      setState(() => _uiState = _BankUiState.notVerified);
    } catch (error) {
      setState(() {
        _uiState = _BankUiState.error;
        _errorMessage = CustomerErrorCopy.message(error);
      });
    }
  }

  String? _statusLine() {
    return switch (_uiState) {
      _BankUiState.verified => 'Bank account verified.',
      _BankUiState.notVerified =>
        _lastResult?.message ?? 'Bank account could not be verified.',
      _BankUiState.nameMismatch => 'Name does not match bank records.',
      _ => null,
    };
  }

  Color _statusColor() {
    return switch (_uiState) {
      _BankUiState.verified => AppColors.successFill,
      _BankUiState.notVerified || _BankUiState.nameMismatch =>
        AppColors.burgundyDeep,
      _ => AppColors.slateMist,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusLine = _statusLine();

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppTopBar.detail(title: 'Bank account'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Verify your bank account', style: AppTypography.headingMD),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Penny-drop verification via our KYC partner. Used for payouts and high-value scheme redemptions.',
              style: AppTypography.uiBodySM.copyWith(color: AppColors.slateMist),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextInput(
              label: 'Account number',
              placeholder: '9–18 digits',
              value: _maskedAccount ?? _accountNumber,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: _uiState == _BankUiState.error ? _errorMessage : null,
              onChanged: (value) {
                if (_maskedAccount != null) {
                  return;
                }
                setState(() {
                  _accountNumber = value;
                  if (_uiState == _BankUiState.error) {
                    _uiState = _BankUiState.idle;
                    _errorMessage = null;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextInput(
              label: 'IFSC',
              placeholder: 'ICIC0001234',
              value: _ifsc,
              onChanged: (value) => setState(() {
                _ifsc = value.toUpperCase();
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextInput(
              label: 'Account holder name',
              placeholder: 'As per bank records',
              value: _name,
              onChanged: (value) => setState(() {
                _name = value;
                if (_uiState == _BankUiState.nameMismatch) {
                  _uiState = _BankUiState.idle;
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
            if (_lastResult?.nameAtBankMasked != null &&
                _uiState == _BankUiState.nameMismatch) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Name at bank: ${_lastResult!.nameAtBankMasked}',
                style: AppTypography.uiBodySM.copyWith(
                  color: AppColors.slateMist,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _uiState == _BankUiState.nameMismatch
                  ? 'Try again'
                  : 'Verify account',
              isFullWidth: true,
              isLoading: _loading,
              onTap: _loading ? null : _verify,
            ),
            const SizedBox(height: AppSpacing.sm),
            GhostButton(
              label: 'Skip to selfie',
              onTap: () => context.push(AppRoutes.profileKycSelfie),
            ),
          ],
        ),
      ),
    );
  }
}
