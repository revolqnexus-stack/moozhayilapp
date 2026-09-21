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
import '../../../core/utils/phone_utils.dart';
import '../../vault/providers/vault_provider.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerWidget {
  const OtpScreen({super.key, this.from});

  final String? from;

  String _maskedPhone(String phone) {
    final normalized = normalizeIndianPhone(phone);
    if (normalized.length >= 13) {
      return '+91 XXXXX ${normalized.substring(normalized.length - 4)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final state = auth.value ?? const AuthState();

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.maroon),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLG),
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
                onChanged: ref.read(authControllerProvider.notifier).setOtp,
                onCompleted: () => _verify(context, ref),
              ),
              if (auth.hasError) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorState(
                  headline: _errorHeadline(auth.error),
                  body: CustomerErrorCopy.message(auth.error),
                  onRetry: () => _retryAfterError(ref),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Verify and Continue',
                isFullWidth: true,
                isLoading: auth.isLoading,
                isDisabled: state.otp.length != 6,
                onTap: () => _verify(context, ref),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => _resendCode(context, ref),
                  child: Text(
                    'Send a new code',
                    style: AppTypography.buttonLabelSM.copyWith(
                      color: AppColors.maroon,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _errorHeadline(Object? error) {
    if (error is ApiException &&
        (error.code == 'PROVIDER_UNAVAILABLE' ||
            error.code == 'RATE_LIMITED')) {
      return 'We couldn\u2019t send a code';
    }

    return 'That code did not work';
  }

  Future<void> _retryAfterError(WidgetRef ref) async {
    final error = ref.read(authControllerProvider).error;
    if (error is ApiException &&
        (error.code == 'PROVIDER_UNAVAILABLE' ||
            error.code == 'RATE_LIMITED')) {
      await ref.read(authControllerProvider.notifier).sendOtp();
      return;
    }

    await ref.read(authControllerProvider.notifier).verifyOtp();
  }

  Future<void> _resendCode(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).sendOtp();
    if (!context.mounted) {
      return;
    }

    if (ref.read(authControllerProvider).hasError) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A new code was sent to ${_maskedPhone(ref.read(authControllerProvider).value?.phone ?? '')}.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verify(BuildContext context, WidgetRef ref) async {
    final user = await () async {
      try {
        return await ref.read(authControllerProvider.notifier).verifyOtp();
      } catch (_) {
        return null;
      }
    }();
    if (!context.mounted) {
      return;
    }

    if (user == null) {
      return;
    }

    if (user.name == null || user.name!.isEmpty) {
      await ref.read(vaultActionsProvider.notifier).syncGuestVaultAfterAuth();
      if (!context.mounted) {
        return;
      }
      context.go(AppRoutes.onboardingIntent);
      return;
    }

    await ref.read(vaultActionsProvider.notifier).syncGuestVaultAfterAuth();
    if (!context.mounted) {
      return;
    }

    context.go(from ?? AppRoutes.home);
  }
}
