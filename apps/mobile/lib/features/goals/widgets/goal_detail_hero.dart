import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/goal.dart';
import '../../../components/progress/linear_progress_bar.dart';
import '../../../core/animations/gold_progress_ring.dart';

/// Ink hero for active plan detail — mirrors [MyGoldHero] structure.
class GoalDetailHero extends StatelessWidget {
  const GoalDetailHero({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.statusLabel.toUpperCase(),
            style: AppTypography.uiMicro.copyWith(
              color: AppColors.gold,
              letterSpacing: 9 * 0.28,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            goal.name,
            style: AppTypography.displayLG.copyWith(
              color: AppColors.paper,
              fontWeight: FontWeight.w300,
              fontSize: 28,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GoldProgressRing(
                percent: goal.percentComplete / 100.0,
                size: 72,
                strokeWidth: 5,
                trackColor: AppColors.paper.withValues(alpha: 0.15),
                progressColor: AppColors.gold,
                showPercentage: false,
                centerWidget: Text(
                  '${goal.percentComplete}%',
                  style: AppTypography.uiLabel.copyWith(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.currentGramsDisplay,
                      style: AppTypography.headingMD.copyWith(
                        color: AppColors.paper,
                      ),
                    ),
                    Text(
                      goal.currentValueDisplay,
                      style: AppTypography.uiBodySM.copyWith(
                        color: AppColors.paper.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressBar(
                      percent: goal.percentComplete,
                      trackColor: AppColors.paper.withValues(alpha: 0.12),
                      progressColor: AppColors.gold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
