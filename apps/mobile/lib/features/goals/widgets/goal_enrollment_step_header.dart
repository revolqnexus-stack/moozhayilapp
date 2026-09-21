import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/indian_format.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../providers/goal_create_provider.dart';

enum GoalEnrollmentStep { moment, piece, amount, payment }

class GoalEnrollmentStepHeader extends StatelessWidget {
  const GoalEnrollmentStepHeader({
    super.key,
    required this.step,
    required this.title,
    this.subtitle,
  });

  final GoalEnrollmentStep step;
  final String title;
  final String? subtitle;

  static const _totalSteps = 4;

  int get _stepIndex => switch (step) {
    GoalEnrollmentStep.moment => 1,
    GoalEnrollmentStep.piece => 2,
    GoalEnrollmentStep.amount => 3,
    GoalEnrollmentStep.payment => 4,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP $_stepIndex OF $_totalSteps',
          style: AppTypography.uiMicro.copyWith(
            color: AppColors.gold,
            letterSpacing: 9 * 0.24,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(_totalSteps, (index) {
            final filled = index < _stepIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == _totalSteps - 1 ? 0 : 4,
                ),
                child: Container(
                  height: 2,
                  color: filled
                      ? AppColors.brandBurgundy
                      : AppColors.border.withValues(alpha: 0.8),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: AppTypography.headingMD),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTypography.uiBodySM.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

String goalPaymentSummary({
  required int amountPaise,
  required int durationMonths,
  required GoldenWishSchemeType scheme,
}) {
  final amount = IndianFormat.formatInrPaise(amountPaise);
  return switch (scheme) {
    GoldenWishSchemeType.aura =>
      '$amount/month · $durationMonths installments · pay from Contribute after enroll',
    GoldenWishSchemeType.crest =>
      '$amount advance · pay from Contribute after enroll to lock weight',
    GoldenWishSchemeType.dhanam =>
      '$amount booking · pay from Contribute after enroll',
    GoldenWishSchemeType.goldNidhi =>
      'From $amount per deposit · pay anytime from Contribute',
  };
}
