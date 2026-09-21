import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/vault_item.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/kyc/kyc_gate_coordinator.dart';

Future<void> showGoalStartBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required VaultItem item,
  GoalSuggestion? goalSuggestion,
}) {
  final suggestion = goalSuggestion;
  final monthlyDisplay =
      suggestion?.suggestedMonthlyDisplay ??
      item.affordability.suggestedMonthlyDisplay;
  final months =
      suggestion?.monthsToComplete ?? item.affordability.monthsToAfford;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => GoalStartBottomSheet(
      productName: item.product.name,
      monthlyDisplay: monthlyDisplay,
      months: months,
      onStartGoal: () async {
        Navigator.of(context).pop();
        final user = ref.read(authControllerProvider).value?.user;
        if (user == null) {
          context.push(
            Uri(
              path: AppRoutes.auth,
              queryParameters: {'from': AppRoutes.goalsCreate},
            ).toString(),
          );
          return;
        }
        final allowed = await ensureKycAllowsAction(
          context: context,
          ref: ref,
          reason: KycGateReason.goalCreation,
          returnRoute: AppRoutes.goalsCreate,
        );
        if (!allowed || !context.mounted) return;
        context.push(AppRoutes.goalsCreate);
      },
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}

class GoalStartBottomSheet extends StatelessWidget {
  const GoalStartBottomSheet({
    super.key,
    required this.productName,
    required this.monthlyDisplay,
    required this.months,
    required this.onStartGoal,
    required this.onDismiss,
  });

  final String productName;
  final String monthlyDisplay;
  final int months;
  final VoidCallback onStartGoal;
  final VoidCallback onDismiss;

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
          Text(productName, style: AppTypography.headingSM),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'At $monthlyDisplay, you\'ll reach this in $months months.',
            style: AppTypography.uiBodySM.copyWith(color: AppColors.slateMist),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Start Aura Plan',
            isFullWidth: true,
            onTap: onStartGoal,
          ),
          const SizedBox(height: AppSpacing.sm),
          GhostButton(label: 'Customise amount →', onTap: onDismiss),
        ],
      ),
    );
  }
}

Future<void> showGuestVaultPrompt({
  required BuildContext context,
  required VoidCallback onSignIn,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.bottomSheet),
          topRight: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Saved to Dream Vault', style: AppTypography.headingSM),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sign in to sync your saved pieces across devices.',
            style: AppTypography.uiBodySM.copyWith(color: AppColors.slateMist),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Sign in',
            isFullWidth: true,
            onTap: () {
              Navigator.of(context).pop();
              onSignIn();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          GhostButton(
            label: 'Not now',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}
