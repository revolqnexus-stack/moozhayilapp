import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/goal.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/kyc/kyc_gate_coordinator.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final goals = ref.watch(goalsListProvider());

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.maroon,
        foregroundColor: AppColors.pureWhite,
        onPressed: () =>
            _startCreate(context, ref, auth.value?.user?.kycStatus),
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
      ),
      body: goals.when(
        data: (response) {
          if (response.goals.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text('My Plans', style: AppTypography.headingLG),
                const SizedBox(height: AppSpacing.lg),
                EmptyState(
                  icon: Icons.flag_outlined,
                  headline: 'Start your jewellery savings journey.',
                  body:
                      'Save monthly with Aura Plan or explore our other schemes.',
                  ctaLabel: 'Explore Schemes',
                  onCtaTap: () => context.go(AppRoutes.goldenWish),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(goalsListProvider());
              await ref.read(goalsListProvider().future);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text('My Plans', style: AppTypography.headingLG),
                const SizedBox(height: AppSpacing.md),
                _SummaryBanner(summary: response.summary),
                const SizedBox(height: AppSpacing.lg),
                ...response.goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: goal.status == 'completed'
                        ? CompletedGoalCard(
                            goal: goal,
                            onTap: () => context.push('/goals/${goal.id}'),
                          )
                        : GoalCard(
                            goal: goal,
                            onTap: () => context.push('/goals/${goal.id}'),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, _) => const LoadingShimmer(
            width: double.infinity,
            height: AppSpacing.x3l * 2,
          ),
        ),
        error: (error, _) => ErrorState(
          body: CustomerErrorCopy.message(error),
          onRetry: () => ref.invalidate(goalsListProvider()),
        ),
      ),
    );
  }

  Future<void> _startCreate(
    BuildContext context,
    WidgetRef ref,
    String? kycStatus,
  ) async {
    if (kycStatus == null) {
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

    context.push(AppRoutes.goalsCreateMoment);
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.summary});

  final GoalsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.champagneVeil,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total gold saved', style: AppTypography.uiLabel),
          const SizedBox(height: AppSpacing.xs),
          Text(summary.totalGramsDisplay, style: AppTypography.headingMD),
          Text(
            '${summary.totalValueDisplay} · ${CustomerCopy.activePlansCount(summary.activeCount)}',
            style: AppTypography.uiBodySM.copyWith(color: AppColors.slateMist),
          ),
        ],
      ),
    );
  }
}
