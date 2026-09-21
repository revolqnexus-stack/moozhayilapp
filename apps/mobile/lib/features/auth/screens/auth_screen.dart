import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/inputs/text_input.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/phone_utils.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key, this.from});

  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final state = auth.value ?? const AuthState();
    final phoneReady = isValidIndianPhone(normalizeIndianPhone(state.phone));

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
                      onSubmit: (_) => _sendOtp(context, ref),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'We\u2019ll send a 6-digit code to +91 ${state.phone.isEmpty ? 'XXXXXXXXXX' : state.phone}.',
                      style: AppTypography.uiCaption.copyWith(
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (auth.hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      ErrorState(
                        headline: _sendErrorHeadline(auth.error),
                        body: CustomerErrorCopy.message(auth.error),
                        onRetry: () => _sendOtp(context, ref),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'Send OTP',
                      isFullWidth: true,
                      isLoading: auth.isLoading,
                      isDisabled: !phoneReady,
                      onTap: () => _sendOtp(context, ref),
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

  Future<void> _sendOtp(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).sendOtp();
    if (context.mounted && !ref.read(authControllerProvider).hasError) {
      context.go(
        Uri(
          path: AppRoutes.authOtp,
          queryParameters: from == null ? null : {'from': from},
        ).toString(),
      );
    }
  }

  String _sendErrorHeadline(Object? error) {
    if (error is ApiException && error.code == 'PROVIDER_UNAVAILABLE') {
      return 'We couldn\u2019t send a code';
    }

    return 'We could not send the OTP';
  }
}
