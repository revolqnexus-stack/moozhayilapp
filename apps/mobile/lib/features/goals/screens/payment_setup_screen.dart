import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/editorial/editorial_panel.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/goal_create_provider.dart';
import '../widgets/goal_enrollment_step_header.dart';

class PaymentSetupScreen extends ConsumerWidget {
  const PaymentSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(goalCreateDraftStoreProvider);
    final summary = goalPaymentSummary(
      amountPaise: draft.monthlyAmountPaise,
      durationMonths: draft.durationMonths,
      scheme: draft.schemeType,
    );

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'Payment setup'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GoalEnrollmentStepHeader(
              step: GoalEnrollmentStep.payment,
              title: 'Review your plan',
              subtitle: draft.schemeType.isLumpSum ||
                      draft.schemeType.isRateProtected
                  ? 'Step 1 creates your plan. Step 2 collects your advance to secure your booking.'
                  : 'Enrollment creates your plan. Pay installments from Contribute when you are ready.',
            ),
            const SizedBox(height: AppSpacing.lg),
            EditorialPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.schemeType.displayName.toUpperCase(),
                    style: AppTypography.uiMicro.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(draft.name, style: AppTypography.headingSM),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    summary,
                    style: AppTypography.uiBodyMD.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Review & confirm',
              isFullWidth: true,
              onTap: () => context.push(AppRoutes.goalsCreateConfirmation),
            ),
          ],
        ),
      ),
    );
  }
}
