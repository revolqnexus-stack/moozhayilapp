import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';

enum KycGateReason { goalCreation, contribution }

extension KycGateReasonCopy on KycGateReason {
  String get headline {
    switch (this) {
      case KycGateReason.goalCreation:
        return 'Verify to join a Scheme';
      case KycGateReason.contribution:
        return 'Verify to contribute to your Scheme';
    }
  }

  String get body {
    switch (this) {
      case KycGateReason.goalCreation:
        return CustomerCopy.kycGateGoalBody;
      case KycGateReason.contribution:
        return CustomerCopy.kycGateContributionBody;
    }
  }
}

Future<void> showKycGateBottomSheet({
  required BuildContext context,
  required KycGateReason reason,
  required String returnRoute,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        KycGateBottomSheet(reason: reason, returnRoute: returnRoute),
  );
}

class KycGateBottomSheet extends StatelessWidget {
  const KycGateBottomSheet({
    super.key,
    required this.reason,
    required this.returnRoute,
  });

  final KycGateReason reason;
  final String returnRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.bottomSheet),
          topRight: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSpacing.bottomSheetHandleWidth,
              height: AppSpacing.bottomSheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.smokeLine,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(reason.headline, style: AppTypography.headingSM),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reason.body,
            style: AppTypography.uiBodySM.copyWith(color: AppColors.slateMist),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Continue verification',
            isFullWidth: true,
            onTap: () {
              Navigator.of(context).pop();
              context.push(
                Uri(
                  path: AppRoutes.profileKyc,
                  queryParameters: {'from': returnRoute},
                ).toString(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          GhostButton(
            label: 'Skip for now',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
