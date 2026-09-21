import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/editorial/editorial_panel.dart';
import '../../../components/editorial/section_header.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../components/overlays/confirmation_bottom_sheet.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/indian_format.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/goal.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_detail_hero.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  var _closingPlan = false;

  bool _canClosePlan(Goal goal) {
    if (goal.status == 'completed' ||
        goal.status == 'cancelled' ||
        goal.status == 'discontinued') {
      return false;
    }

    return goal.schemeType == 'crest' ||
        goal.schemeType == 'dhanam' ||
        goal.schemeType == 'gold_nidhi';
  }

  Future<void> _confirmClosePlan(Goal goal) async {
    await showConfirmationSheet(
      context: context,
      title: 'Close plan',
      body: 'Your gold stays in My Gold. This plan will close.',
      confirmLabel: 'Close plan',
      cancelLabel: 'Keep plan',
      isDestructive: true,
      onConfirm: () => _closePlan(goal.id),
    );
  }

  Future<void> _closePlan(String goalId) async {
    if (_closingPlan) return;

    setState(() => _closingPlan = true);

    try {
      await ref.read(goalsRepositoryProvider).cancel(goalId);
      ref.invalidate(goalsListProvider);
      ref.invalidate(goalDetailProvider(goalId));

      if (!mounted) return;
      showPremiumSnackBar(
        context,
        'Plan closed. Your gold remains in My Gold.',
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      showPremiumSnackBar(
        context,
        CustomerErrorCopy.message(error),
        haptic: false,
      );
      setState(() => _closingPlan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(goalDetailProvider(widget.goalId));

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'My Plan'),
      body: detail.when(
        data: (response) {
          final goal = response.goal;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(goalDetailProvider(widget.goalId));
              await ref.read(goalDetailProvider(widget.goalId).future);
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.x3l),
              children: [
                GoalDetailHero(goal: goal),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${goal.currentGramsDisplay} of ${goal.targetGrams ?? goal.targetAmountDisplay ?? 'target'}',
                        style: AppTypography.uiBodySM.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionHeader(
                        eyebrow: 'Plan details',
                        title: 'Summary',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      EditorialPanel(
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Installment',
                              value: goal.monthlyAmountDisplay,
                            ),
                            _InfoRow(
                              label: 'Next due',
                              value: goal.nextContributionDate,
                            ),
                            if (goal.schemeType == 'aura') ...[
                              if (goal.installmentsTotal != null)
                                _InfoRow(
                                  label: 'Progress',
                                  value:
                                      '${goal.installmentsCompleted ?? 0} of ${goal.installmentsTotal} installments',
                                ),
                              if (goal.maturityDate != null)
                                _InfoRow(
                                  label: 'Maturity',
                                  value: goal.maturityDate!,
                                ),
                              if (goal.redemptionWindowStart != null &&
                                  goal.redemptionWindowEnd != null)
                                _InfoRow(
                                  label: 'Redemption window',
                                  value:
                                      '${goal.redemptionWindowStart} – ${goal.redemptionWindowEnd}',
                                ),
                              _InfoRow(
                                label: 'Making-charge benefit',
                                value: goal.mcWaiverActive
                                    ? 'Active — 0% on jewellery via My Gold checkout'
                                    : goal.mcWaiverEligible
                                    ? 'Eligible — opens ${goal.redemptionWindowStart ?? 'at maturity'} (My Gold checkout)'
                                    : 'Not yet eligible',
                              ),
                            ] else
                              _InfoRow(
                                label: 'Est. completion',
                                value: goal.estimatedCompletionDate,
                              ),
                          ],
                        ),
                      ),
                      if (goal.status != 'completed' &&
                          goal.status != 'cancelled' &&
                          goal.status != 'discontinued') ...[
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: 'Make a contribution',
                          isFullWidth: true,
                          onTap: () => context.push(
                            '/goals/${widget.goalId}/contribute',
                          ),
                        ),
                      ],
                      if (_canClosePlan(goal)) ...[
                        const SizedBox(height: AppSpacing.md),
                        GhostButton(
                          label: _closingPlan ? 'Closing plan…' : 'Close plan',
                          isDisabled: _closingPlan,
                          onTap: _closingPlan
                              ? null
                              : () => _confirmClosePlan(goal),
                        ),
                      ],
                      if (response.contributions.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        const SectionHeader(
                          eyebrow: 'Activity',
                          title: 'Recent contributions',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...response.contributions.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: EditorialPanel(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          IndianFormat.formatInrPaise(
                                            item.amountPaise,
                                          ),
                                          style: AppTypography.priceTabular,
                                        ),
                                        Text(
                                          item.contributionMonth,
                                          style: AppTypography.uiBodySM
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    item.status.toUpperCase(),
                                    style: AppTypography.uiMicro.copyWith(
                                      color: AppColors.textMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LoadingShimmer(width: double.infinity, height: 240),
        ),
        error: (error, _) => ErrorState(
          body: CustomerErrorCopy.message(error),
          onRetry: () => ref.invalidate(goalDetailProvider(widget.goalId)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.uiBodySM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.uiBodySM.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
