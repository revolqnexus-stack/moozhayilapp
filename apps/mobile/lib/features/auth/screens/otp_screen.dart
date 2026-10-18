import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/inputs/otp_dot_field.dart';
import '../../../core/config/staging_config.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/phone_utils.dart';
import '../../vault/providers/vault_provider.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.from});

  final String? from;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  Timer? _resendTimer;
  int _resendSeconds = 0;
  String? _countdownForSessionId;

  @override
  void initState() {
    super.initState();
    // Start the resend cooldown if a challenge is already present on entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final challenge = ref.read(authControllerProvider).value?.otpChallenge;
      if (challenge != null) {
        _startResendCountdown(
          challenge.otpSessionId,
          challenge.resendAllowedAfterSeconds,
        );
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown(String sessionId, int seconds) {
    _resendTimer?.cancel();
    _countdownForSessionId = sessionId;
    setState(() => _resendSeconds = seconds);
    if (seconds <= 0) return;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendSeconds -= 1;
        if (_resendSeconds <= 0) {
          _resendSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  String _maskedPhone(String phone) {
    final normalized = normalizeIndianPhone(phone);
    if (normalized.length >= 13) {
      return '+91 XXXXX ${normalized.substring(normalized.length - 4)}';
    }
    return phone;
  }

  String _resendLabel() {
    if (_resendSeconds <= 0) return 'Send a new code';
    final m = _resendSeconds ~/ 60;
    final s = _resendSeconds % 60;
    return 'Resend in ${m == 0 ? '0' : m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Restart the cooldown whenever a *new* challenge arrives (e.g. a resend).
    ref.listen(authControllerProvider, (previous, next) {
      final challenge = next.value?.otpChallenge;
      if (challenge != null &&
          challenge.otpSessionId != _countdownForSessionId) {
        _startResendCountdown(
          challenge.otpSessionId,
          challenge.resendAllowedAfterSeconds,
        );
      }
    });

    final state = ref.watch(authControllerProvider).value ?? const AuthState();
    final isSending = state.otpSendInProgress && state.otpChallenge == null;
    final isVerifying = state.otpVerifyInProgress;
    final sendError = state.sendOtpError;
    final verifyError = state.verifyOtpError;
    final canResend = _resendSeconds <= 0 && !isVerifying && !isSending;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.maroon),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: AutofillGroup(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingLG),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        'Enter the code to verify your phone',
                        style: AppTypography.headingXL,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'We sent an SMS with a code to ${_maskedPhone(state.phone)}.',
                        style: AppTypography.uiBodyMD.copyWith(
                          color: AppColors.slateMist,
                          height: 1.5,
                        ),
                      ),
                      if (isSending) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sending your code\u2026',
                          style: AppTypography.uiCaption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (stagingOtpHint.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          stagingOtpHint,
                          style: AppTypography.uiCaption.copyWith(
                            color: AppColors.gold,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      OtpDotField(
                        value: state.otp,
                        onChanged: ref
                            .read(authControllerProvider.notifier)
                            .setOtp,
                        onCompleted: () => _verify(),
                      ),
                      if (sendError != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        ErrorState(
                          headline: _sendErrorHeadline(sendError),
                          body: CustomerErrorCopy.message(sendError),
                          onRetry: () => _resend(),
                        ),
                      ] else if (verifyError != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        ErrorState(
                          headline: _verifyErrorHeadline(verifyError),
                          body: CustomerErrorCopy.message(verifyError),
                          onRetry: () => _verify(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      PrimaryButton(
                        label: 'Verify and Continue',
                        isFullWidth: true,
                        isLoading: isVerifying,
                        isDisabled:
                            state.otp.length != 6 || isVerifying || isSending,
                        onTap: () => _verify(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: TextButton(
                          onPressed: canResend ? () => _resend() : null,
                          child: Text(
                            _resendLabel(),
                            style: AppTypography.buttonLabelSM.copyWith(
                              color: canResend
                                  ? AppColors.maroon
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _verifyErrorHeadline(Object? error) {
    if (error is ApiException &&
        (error.code == 'PROVIDER_UNAVAILABLE' ||
            error.code == 'RATE_LIMITED')) {
      return 'We couldn\u2019t verify that code';
    }
    return 'That code did not work';
  }

  String _sendErrorHeadline(Object? error) {
    if (error is ApiException && error.code == 'PROVIDER_UNAVAILABLE') {
      return 'We couldn\u2019t send a code';
    }
    if (error is ApiException && error.code == 'RATE_LIMITED') {
      return 'Too many attempts';
    }
    return 'We could not send the OTP';
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    await ref.read(authControllerProvider.notifier).sendOtp();
    if (!mounted) return;

    final hasError =
        ref.read(authControllerProvider).value?.sendOtpError != null;
    if (hasError) {
      return;
    }

    final phone = ref.read(authControllerProvider).value?.phone ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A new code was sent to ${_maskedPhone(phone)}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verify() async {
    final user = await ref.read(authControllerProvider.notifier).verifyOtp();
    if (!mounted || user == null) {
      return;
    }

    AppHaptics.light();

    // Navigate first; sync the guest vault in the background so routing is not
    // blocked on it.
    unawaited(
      ref.read(vaultActionsProvider.notifier).syncGuestVaultAfterAuth(),
    );

    if (user.name == null || user.name!.isEmpty) {
      context.go(AppRoutes.onboardingIntent);
      return;
    }

    context.go(widget.from ?? AppRoutes.home);
  }
}
