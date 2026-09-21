import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../core/animations/section_reveal.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/kyc_thresholds.dart';
import '../../../core/constants/motion.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../goals/providers/goal_create_provider.dart';
import '../../goals/providers/goals_provider.dart';
import '../../goals/widgets/goal_card.dart';
import '../../home/widgets/live_gold_rate_strip.dart';
import '../../my_gold/providers/gold_balance_provider.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/time/server_clock_provider.dart';
import '../../profile/widgets/kyc_gate_bottom_sheet.dart';
import '../../shop/widgets/shop_section.dart';
import '../models/golden_wish_plan.dart';
import '../widgets/golden_wish_home_band.dart';
import '../widgets/plan_card.dart';

class GoldenWishScreen extends ConsumerStatefulWidget {
  const GoldenWishScreen({super.key});

  @override
  ConsumerState<GoldenWishScreen> createState() => _GoldenWishScreenState();
}

class _GoldenWishScreenState extends ConsumerState<GoldenWishScreen> {
  final _plansSectionKey = GlobalKey();

  void _scrollToPlans() {
    final target = _plansSectionKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: AppMotion.normal,
        curve: AppMotion.emphasized,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final plans = ref.watch(goalsListProvider());
    final goldRate = ref.watch(goldBalanceProvider);
    final clock = ref.watch(serverClockProvider);
    final isOffline = ref.watch(isOfflineProvider);

    final isRateLoading = goldRate.isLoading;
    final isRateRefreshing = goldRate.isLoading && goldRate.hasValue;
    final ratePaise = goldRate.maybeWhen(
      data: (balance) => balance.rateUsed.ratePaise,
      orElse: () => null,
    );
    final rateDisplay = goldRate.maybeWhen(
      data: (balance) => balance.rateUsed.rateDisplay,
      orElse: () => null,
    );
    final rateUpdatedAt = goldRate.maybeWhen(
      data: (balance) => balance.rateUsed.updatedAt,
      orElse: () => null,
    );
    final purityLabel = goldRate.maybeWhen(
      data: (balance) => _formatPurity(balance.rateUsed.purity),
      orElse: () => '22KT',
    );

    return ColoredBox(
      color: AppColors.paper,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(goalsListProvider());
          ref.invalidate(goldBalanceProvider);
          await ref.read(goalsListProvider().future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.x3l),
          children: [
            SectionReveal(
              index: 0,
              child: GoldenWishHomeBand(
                ctaLabel: CustomerCopy.schemesBrowsePlansCta,
                onExplorePlans: _scrollToPlans,
              ),
            ),
            SectionReveal(
              index: 1,
              child: LiveGoldRateStrip(
                ratePaise: ratePaise,
                rateDisplay: rateDisplay,
                rateUpdatedAtIso: rateUpdatedAt,
                clock: clock,
                purityLabel: purityLabel,
                isLoading: isRateLoading,
                isRefreshing: isRateRefreshing,
                isOffline: isOffline,
              ),
            ),
            SectionReveal(
              index: 2,
              child: KeyedSubtree(
                key: _plansSectionKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShopSectionInset(
                      top: 8,
                      bottom: 12,
                      child: ShopSectionHeader(
                        title: CustomerCopy.schemesPurchasePlansTitle,
                        subtitle:
                            'Choose a plan that fits your family\u2019s milestone.',
                      ),
                    ),
                    ...goldenWishPlans.map(
                      (plan) => Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.homeScreenPadding,
                          0,
                          AppSpacing.homeScreenPadding,
                          AppSpacing.md,
                        ),
                        child: PlanCard(
                          plan: plan,
                          onLearnMore: () => context.push(
                            AppRoutes.goldenWishPlanDetail(plan.routeSlug),
                          ),
                          onJoinNow: () => _startEnrollment(
                            context,
                            ref,
                            auth.value?.user?.kycStatus,
                            plan,
                          ),
                          onVisitShowroom: () =>
                              context.push(AppRoutes.storeLocator),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SectionReveal(
              index: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.homeScreenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    ShopSectionHeader(
                      title: CustomerCopy.myPlansSectionTitle,
                      actionLabel: 'View all',
                      onAction: () => context.push(AppRoutes.myPlans),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    plans.when(
                      data: (response) {
                        if (response.goals.isEmpty) {
                          return EmptyState(
                            icon: Icons.auto_awesome_outlined,
                            headline: CustomerCopy.myPlansEmptyHeadlineInline,
                            body: CustomerCopy.myPlansEmptyBodyInline,
                            ctaLabel: CustomerCopy.exploreSchemesCta,
                            onCtaTap: _scrollToPlans,
                          );
                        }

                        return Column(
                          children: response.goals
                              .map(
                                (goal) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: goal.status == 'completed'
                                      ? CompletedGoalCard(
                                          goal: goal,
                                          onTap: () =>
                                              context.push('/goals/${goal.id}'),
                                        )
                                      : GoalCard(
                                          goal: goal,
                                          onTap: () =>
                                              context.push('/goals/${goal.id}'),
                                        ),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                      loading: () => Column(
                        children: List.generate(
                          2,
                          (_) => const Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.md),
                            child: LoadingShimmer(
                              width: double.infinity,
                              height: AppSpacing.x3l * 2,
                            ),
                          ),
                        ),
                      ),
                      error: (error, _) => ErrorState(
                        body: CustomerErrorCopy.message(error),
                        onRetry: () => ref.invalidate(goalsListProvider()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startEnrollment(
    BuildContext context,
    WidgetRef ref,
    String? kycStatus,
    GoldenWishPlan plan,
  ) {
    if (kycStatus == null) {
      context.push(
        Uri(
          path: AppRoutes.auth,
          queryParameters: {'from': AppRoutes.goalsCreate},
        ).toString(),
      );
      return;
    }

    if (!isKycVerified(kycStatus)) {
      showKycGateBottomSheet(
        context: context,
        reason: KycGateReason.goalCreation,
        returnRoute: AppRoutes.goalsCreate,
      );
      return;
    }

    final scheme = GoldenWishSchemeType.fromApiValue(plan.schemeType);
    ref.read(goalCreateDraftStoreProvider.notifier).setScheme(scheme);
    context.push(AppRoutes.goalsCreateMoment);
  }

  String _formatPurity(String purity) {
    final normalized = purity.trim().toLowerCase();
    if (normalized.endsWith('k') || normalized.endsWith('kt')) {
      return normalized.toUpperCase().replaceAll('K', 'KT');
    }
    return '${normalized.toUpperCase()}KT';
  }
}
