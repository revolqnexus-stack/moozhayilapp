import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/animations/kyc_verified_seal.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/kyc_thresholds.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/kyc_provider.dart';

class KycPendingScreen extends ConsumerStatefulWidget {
  const KycPendingScreen({super.key, this.returnRoute});

  final String? returnRoute;

  @override
  ConsumerState<KycPendingScreen> createState() => _KycPendingScreenState();
}

class _KycPendingScreenState extends ConsumerState<KycPendingScreen> {
  @override
  Widget build(BuildContext context) {
    final status = ref.watch(kycStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppTopBar.detail(title: 'Verification Pending'),
      body: status.when(
        data: (kyc) {
          final verified = isKycVerified(kyc.kycStatus);

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (verified) ...[
                  Center(child: const KycVerifiedSeal(size: 120)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                  verified
                      ? 'Verification complete'
                      : 'We are reviewing your documents',
                  style: AppTypography.headingMD,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  verified
                      ? 'You are now a verified member.'
                      : CustomerCopy.kycPendingReviewSla(
                          KycThresholds.estimatedReviewMinutes,
                        ),
                  style: AppTypography.uiBodyMD.copyWith(
                    color: AppColors.slateMist,
                  ),
                ),
                if (kyc.kycStatus == 'rejected' &&
                    kyc.rejectionReason != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    kyc.rejectionReason!,
                    style: AppTypography.uiBodySM.copyWith(
                      color: AppColors.blushClay,
                    ),
                  ),
                  if (kyc.resubmissionAllowedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'Resubmission opens after the ${KycThresholds.resubmissionCooldownHours}-hour cooldown.',
                        style: AppTypography.uiCaption,
                      ),
                    ),
                ],
                const Spacer(),
                PrimaryButton(
                  label: verified ? 'Continue' : 'Back to profile',
                  isFullWidth: true,
                  onTap: () {
                    if (verified && widget.returnRoute != null) {
                      context.go(widget.returnRoute!);
                    } else {
                      context.go(AppRoutes.profile);
                    }
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
