import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/indian_format.dart';
import '../providers/goal_create_provider.dart';
import '../widgets/goal_enrollment_step_header.dart';

class AmountScreen extends ConsumerWidget {
  const AmountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(goalCreateDraftStoreProvider);
    final scheme = draft.schemeType;
    final minRupees = scheme.minAmountPaise ~/ 100;
    final maxRupees = scheme.maxAmountPaise ~/ 100;
    final stepRupees = scheme.stepPaise ~/ 100;
    final amountRupees = draft.monthlyAmountPaise ~/ 100;
    final snappedRupees = ((amountRupees / stepRupees).round() * stepRupees)
        .clamp(minRupees, maxRupees);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: scheme.displayName),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GoalEnrollmentStepHeader(
              step: GoalEnrollmentStep.amount,
              title: draft.amountLabel,
              subtitle:
                  'Minimum ${IndianFormat.formatInrPaise(minRupees * 100)} · multiples of ${IndianFormat.formatInrPaise(stepRupees * 100)}',
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              IndianFormat.formatInrPaise(snappedRupees * 100),
              style: AppTypography.displayLG.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: AppColors.textPrimary,
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.brandBurgundy,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.brandBurgundy,
                overlayColor: AppColors.brandBurgundy.withValues(alpha: 0.12),
              ),
              child: Slider(
                value: snappedRupees.toDouble(),
                min: minRupees.toDouble(),
                max: maxRupees.toDouble(),
                divisions: (maxRupees - minRupees) ~/ stepRupees,
                label: IndianFormat.formatInrPaise(snappedRupees * 100),
                onChanged: (value) {
                  final amount = ((value / stepRupees).round() * stepRupees)
                      .clamp(minRupees, maxRupees);
                  ref
                      .read(goalCreateDraftStoreProvider.notifier)
                      .setMonthlyAmount(amount * 100);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Plan terms', style: AppTypography.headingSM),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _termsCopy(scheme),
              style: AppTypography.uiBodyMD.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              isFullWidth: true,
              onTap: () => context.push(AppRoutes.goalsCreatePayment),
            ),
          ],
        ),
      ),
    );
  }

  String _termsCopy(GoldenWishSchemeType scheme) => switch (scheme) {
    GoldenWishSchemeType.aura =>
      '11 monthly installments · maturity after 11 payments · redemption window from day 332\n\n'
          'Making-charge benefit (Aura only): 0% on jewellery when checking out with My Gold '
          'during the redemption window (days 332–352), after all 11 installments are paid.\n\n'
          'Two consecutive missed monthly installments will discontinue your Aura Plan. '
          'Gold accumulated so far stays in your My Gold balance.',
    GoldenWishSchemeType.crest =>
      'Single advance payment · gold weight locked immediately at today\u2019s rate',
    GoldenWishSchemeType.dhanam =>
      '12-month booking · lower of booking-day or redemption-day rate applies',
    GoldenWishSchemeType.goldNidhi =>
      'Open-ended plan · deposit any time from ${IndianFormat.formatInrPaise(50000)} · no fixed maturity',
  };
}
