import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/buttons/secondary_button.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';

class KycIntroScreen extends StatelessWidget {
  const KycIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Verification keeps gold safe.',
                style: AppTypography.headingXL,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                CustomerCopy.kycUnlockSchemes,
                style: AppTypography.uiBodyLG.copyWith(
                  color: AppColors.slateMist,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Go to KYC',
                isFullWidth: true,
                onTap: () => context.go(AppRoutes.profileKyc),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: 'I will do this later',
                isFullWidth: true,
                onTap: () => context.go(AppRoutes.home),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
