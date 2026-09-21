import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/animations/luxury_success.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/indian_format.dart';
import '../providers/goal_create_provider.dart';
import '../providers/goals_provider.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  var _submitting = false;
  var _showSuccess = false;
  GoalCreateDraft? _successDraft;

  bool _requiresFirstPaymentHandoff(GoldenWishSchemeType scheme) =>
      scheme.isLumpSum || scheme.isRateProtected;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final draft = ref.read(goalCreateDraftStoreProvider);

    try {
      final response = await ref.read(goalsRepositoryProvider).create(
            schemeType: draft.schemeType.apiValue,
            goalType: draft.goalType,
            name: draft.name.trim(),
            monthlyAmountPaise: draft.monthlyAmountPaise,
            durationMonths: draft.durationMonths,
            startDate: draft.startDate!,
            targetProductId: draft.targetProductId,
          );

      ref.invalidate(goalsListProvider);
      ref.read(goalCreateDraftStoreProvider.notifier).reset();

      if (!mounted) return;

      if (_requiresFirstPaymentHandoff(draft.schemeType)) {
        context.go(
          AppRoutes.goalContributeFirstPayment(
            goalId: response.goal.id,
            amountPaise: draft.monthlyAmountPaise,
          ),
        );
        return;
      }

      setState(() {
        _submitting = false;
        _showSuccess = true;
        _successDraft = draft;
      });
    } catch (error) {
      if (!mounted) return;
      showPremiumSnackBar(context, CustomerCopy.planStartError, haptic: false);
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(goalCreateDraftStoreProvider);
    final scheme = draft.schemeType;
    final amountLabel = IndianFormat.formatInrPaise(draft.monthlyAmountPaise);

    if (_showSuccess && _successDraft != null) {
      final successDraft = _successDraft!;
      final isAura = successDraft.schemeType == GoldenWishSchemeType.aura;
      return LuxurySuccessOverlay(
        title: successDraft.successTitle,
        subtitle: successDraft.successSubtitle,
        sealLetter: isAura ? 'A' : null,
        primaryActionLabel: 'View My Plans',
        onPrimaryAction: () => context.go(AppRoutes.myPlans),
        secondaryActionLabel: 'Explore Jewellery',
        onSecondaryAction: () => context.go(AppRoutes.shop),
        onDone: () {},
      );
    }

    return Scaffold(
      appBar: AppTopBar.detail(title: 'Confirm ${scheme.displayName}'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(draft.name, style: AppTypography.headingMD),
            const SizedBox(height: AppSpacing.md),
            Text(_summaryLine(scheme, amountLabel)),
            const SizedBox(height: AppSpacing.sm),
            Text(_footerLine(scheme), style: AppTypography.uiBodySM),
            if (scheme == GoldenWishSchemeType.aura) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Two consecutive missed installments discontinue the plan. '
                'Your gold stays in My Gold.',
                style: AppTypography.uiBodySM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (_requiresFirstPaymentHandoff(scheme)) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                CustomerCopy.enrollmentHandoffHint,
                style: AppTypography.uiBodySM.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ],
            if (draft.targetProductName != null)
              Text('Toward ${draft.targetProductName}'),
            const Spacer(),
            PrimaryButton(
              label: _submitting
                  ? 'Creating…'
                  : (_requiresFirstPaymentHandoff(scheme)
                      ? 'Create plan & continue'
                      : 'Start my plan'),
              onTap: _submitting || !draft.isValid ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String _summaryLine(GoldenWishSchemeType scheme, String amount) =>
      switch (scheme) {
        GoldenWishSchemeType.aura => '$amount/mo · 11 monthly installments',
        GoldenWishSchemeType.crest =>
          '$amount advance · weight locked on payment',
        GoldenWishSchemeType.dhanam =>
          '$amount booking advance · rate protection for 12 months',
        GoldenWishSchemeType.goldNidhi =>
          '$amount minimum deposit · open-ended savings',
      };

  String _footerLine(GoldenWishSchemeType scheme) => switch (scheme) {
    GoldenWishSchemeType.aura =>
      'Aura: 0% making charges on jewellery when paying with My Gold during '
          'your redemption window (days 332–352), after 11 installments. '
          'Trusted since 1969.',
    _ => 'Trusted since 1969',
  };
}
