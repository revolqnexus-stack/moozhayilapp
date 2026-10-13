import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/inputs/text_input.dart';
import '../../../core/config/staging_config.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/api_warmup.dart';
import '../../../core/utils/phone_utils.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.from});

  final String? from;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(warmProductionApi());
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final state = auth.value ?? const AuthState();
    final phoneReady = isValidIndianPhone(normalizeIndianPhone(state.phone));
    final sendingOtp = state.otpSendInProgress;
    final sendOtpError = state.sendOtpError;

    return Scaffold(
      backgroundColor: AppColors.paper,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingLG),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      'Log in',
                      style: AppTypography.displayItalic(
                        36,
                      ).copyWith(decoration: TextDecoration.none),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Elegance meets mastery.\nWelcome to Moozhayil.',
                      style: AppTypography.uiBodyMD.copyWith(
                        color: AppColors.textMuted,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextInput(
                      label: 'Mobile number',
                      placeholder: '9876543210',
                      value: state.phone,
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: ref
                          .read(authControllerProvider.notifier)
                          .setPhone,
                      onSubmit: (_) => _sendOtp(context),
                    ),
                    if (phoneReady) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'We\u2019ll send a 6-digit code to +91 ${formatIndianPhoneLabel(state.phone)}.',
                        style: AppTypography.uiCaption.copyWith(
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                    if (stagingOtpHint.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        stagingOtpHint,
                        style: AppTypography.uiCaption.copyWith(
                          color: AppColors.gold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                    if (sendOtpError != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      ErrorState(
                        headline: _sendErrorHeadline(sendOtpError),
                        body: CustomerErrorCopy.message(sendOtpError),
                        onRetry: () => _sendOtp(context),
                      ),
                    ],
                    if (sendingOtp) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Sending your code\u2026',
                        style: AppTypography.uiCaption.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: sendingOtp ? 'Sending\u2026' : 'Send OTP',
                      isFullWidth: true,
                      isLoading: sendingOtp,
                      isDisabled: !phoneReady || sendingOtp,
                      onTap: () => _sendOtp(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _sendOtp(BuildContext context) {
    final before = ref.read(authControllerProvider).value ?? const AuthState();
    if (before.otpSendInProgress) {
      return;
    }

    final phone = normalizeIndianPhone(before.phone);
    if (!isValidIndianPhone(phone)) {
      return;
    }

    // Fire the request but don't block the UI on the SMS round-trip. The OTP
    // screen renders a "sending" state and surfaces any send error with retry.
    unawaited(ref.read(authControllerProvider.notifier).sendOtp());

    // Optimistically open the OTP screen immediately.
    context.go(
      Uri(
        path: AppRoutes.authOtp,
        queryParameters: widget.from == null ? null : {'from': widget.from},
      ).toString(),
    );
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
}
