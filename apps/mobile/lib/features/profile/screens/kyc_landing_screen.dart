import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/kyc_thresholds.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/kyc_provider.dart';

class KycLandingScreen extends ConsumerWidget {
  const KycLandingScreen({super.key, this.returnRoute});

  final String? returnRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(kycStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppTopBar.detail(title: 'Member Verification'),
      body: status.when(
        data: (kyc) {
          if (kyc.kycStatus == 'in_review') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go(AppRoutes.profileKycPending);
              }
            });
            return const Center(child: LoadingShimmer(width: 200, height: 24));
          }

          if (isKycVerified(kyc.kycStatus)) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You are verified', style: AppTypography.headingMD),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your profile is ready for Schemes and higher contribution limits.',
                    style: AppTypography.uiBodyMD.copyWith(
                      color: AppColors.slateMist,
                    ),
                  ),
                  if (returnRoute != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: 'Continue',
                      isFullWidth: true,
                      onTap: () => context.go(returnRoute!),
                    ),
                  ],
                ],
              ),
            );
          }

          if (kyc.kycStatus == 'rejected') {
            final cooldown = kyc.resubmissionAllowedAt;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification unsuccessful',
                    style: AppTypography.headingMD,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (kyc.rejectionReason != null)
                    Text(
                      kyc.rejectionReason!,
                      style: AppTypography.uiBodyMD.copyWith(
                        color: AppColors.slateMist,
                      ),
                    ),
                  if (cooldown != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'You can resubmit after the ${KycThresholds.resubmissionCooldownHours}-hour cooldown.',
                      style: AppTypography.uiCaption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: cooldown == null
                        ? 'Resubmit verification'
                        : 'Back to profile',
                    isFullWidth: true,
                    onTap: cooldown == null
                        ? () => context.push(AppRoutes.profileKycPan)
                        : () => context.go(AppRoutes.profile),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verify your identity', style: AppTypography.headingMD),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Required only when you join or contribute to a Scheme. '
                  'Shopping and checkout work without verification.',
                  style: AppTypography.uiBodyMD.copyWith(
                    color: AppColors.slateMist,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Start verification',
                  isFullWidth: true,
                  onTap: () => context.push(AppRoutes.profileKycPan),
                ),
                const SizedBox(height: AppSpacing.sm),
                GhostButton(
                  label: 'Skip for now',
                  onTap: () {
                    if (returnRoute != null) {
                      context.go(returnRoute!);
                      return;
                    }
                    context.go(AppRoutes.profile);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LoadingShimmer(width: double.infinity, height: AppSpacing.x3l),
        ),
        error: (error, _) => ErrorState(
          body: CustomerErrorCopy.message(error),
          onRetry: () => ref.invalidate(kycStatusProvider),
        ),
      ),
    );
  }
}
