import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/kyc/decide_kyc_gate.dart';
import '../../../core/routing/app_routes.dart';

/// Inline block when My Gold redemption requires KYC.
class KycRedemptionPanel extends StatelessWidget {
  const KycRedemptionPanel({
    super.key,
    required this.block,
    this.isLoading = false,
    this.returnRoute = AppRoutes.myGold,
  });

  final KycGateBlock block;
  final bool isLoading;
  final String returnRoute;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingShimmer(width: double.infinity, height: 96);
    }

    return Semantics(
      container: true,
      label: CustomerCopy.kycRedemptionPanelTitle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.warmIvory,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Verification required',
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.gold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CustomerCopy.kycRedemptionPanelTitle,
                        style: AppTypography.headingSM.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        CustomerCopy.kycRedemptionPanelBody,
                        style: AppTypography.uiBodySM.copyWith(
                          color: AppColors.slateMist,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (block.state == KycBlockState.notStarted ||
                block.state == KycBlockState.rejected) ...[
              const SizedBox(height: AppSpacing.md),
              Semantics(
                button: true,
                label: 'Continue verification',
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Continue verification',
                    isFullWidth: true,
                    onTap: () => context.push(
                      Uri(
                        path: AppRoutes.profileKyc,
                        queryParameters: {'from': returnRoute},
                      ).toString(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
