import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../core/animations/section_reveal.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../components/icons/plan_monogram_seal.dart';
import '../../auth/providers/auth_provider.dart';
import '../../goals/providers/goal_create_provider.dart';
import '../../../core/kyc/kyc_gate_coordinator.dart';
import '../../shop/widgets/shop_section.dart';
import '../models/golden_wish_plan.dart';
import '../providers/plans_provider.dart';
import '../widgets/plan_accent.dart';

/// Plan detail under the Schemes tab — shell provides back navigation.
class PlanDetailScreen extends ConsumerStatefulWidget {
  const PlanDetailScreen({super.key, required this.planSlug});

  final String planSlug;

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  var _submittingInterest = false;

  @override
  Widget build(BuildContext context) {
    final plan = goldenWishPlanBySlug(widget.planSlug);
    if (plan == null) {
      return const ColoredBox(
        color: AppColors.paper,
        child: Center(child: Text('Plan not found')),
      );
    }

    final accent = PlanAccent.forPlan(plan.id);
    final interests = ref.watch(myPlanInterestsProvider);
    final schemeType = PlanAccent.schemeTypeFor(plan.id);
    final alreadyRegistered = interests.maybeWhen(
      data: (schemes) => schemes.contains(schemeType),
      orElse: () => false,
    );

    return ColoredBox(
      color: AppColors.paper,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.x3l),
        children: [
          SectionReveal(
            index: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: accent.background,
              child: Row(
                children: [
                  PlanMonogramSeal(
                    letter: accent.monogram,
                    accentColor: accent.accent,
                    size: 44,
                    backgroundColor: accent.background,
                    borderColor: accent.accent.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.tagline.toUpperCase(),
                          style: AppTypography.uiMicro.copyWith(
                            color: accent.accent,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.title,
                          style: AppTypography.headingMD.copyWith(
                            color: accent.titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ShopSectionInset(
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionReveal(
                  index: 1,
                  child: Text(
                    plan.detailHeadline,
                    style: AppTypography.headingLG,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SectionReveal(
                  index: 2,
                  child: Text(
                    plan.detailBody,
                    style: AppTypography.uiBodyMD.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionReveal(
                  index: 3,
                  child: ShopSectionHeader(
                    title: 'Plan highlights',
                    subtitle: plan.summary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...plan.highlights.asMap().entries.map(
                  (entry) => SectionReveal(
                    index: 4 + entry.key,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Container(
                              width: 4,
                              height: 4,
                              color: accent.accent,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: AppTypography.uiBodySM.copyWith(
                                height: 1.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!plan.enrollmentAvailable) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SectionReveal(
                    index: 10,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.pearl,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital enrollment opening soon',
                            style: AppTypography.headingSM,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'You can already enroll for ${plan.title} at our Pala showroom. '
                            'Register your interest here and we will notify you when app '
                            'enrollment is ready.',
                            style: AppTypography.uiBodySM.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (alreadyRegistered)
                            Text(
                              'Thank you. Our team will reach out when ${plan.title} '
                              'enrollment is available in the app.',
                              style: AppTypography.uiBodySM.copyWith(
                                color: AppColors.sageWhisper,
                              ),
                            )
                          else
                            PrimaryButton(
                              label: _submittingInterest
                                  ? 'Registering…'
                                  : 'Register interest',
                              isFullWidth: true,
                              isDisabled: _submittingInterest,
                              onTap: _submittingInterest
                                  ? null
                                  : () => _registerInterest(schemeType),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                if (plan.enrollmentAvailable)
                  PrimaryButton(
                    label: 'Join ${plan.title}',
                    isFullWidth: true,
                    onTap: () => _startEnrollment(context, ref, plan),
                  )
                else
                  GhostButton(
                    label: 'Visit our showroom',
                    onTap: () => context.push(AppRoutes.storeLocator),
                  ),
                const SizedBox(height: AppSpacing.sm),
                GhostButton(
                  label: 'Back to Schemes',
                  onTap: () => context.go(AppRoutes.goldenWish),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerInterest(String schemeType) async {
    setState(() => _submittingInterest = true);
    try {
      await ref.read(planInterestActionsProvider.notifier).register(schemeType);
      if (!mounted) return;
      showPremiumSnackBar(context, 'Interest registered. We will be in touch.');
    } catch (error) {
      if (!mounted) return;
      showPremiumSnackBar(
        context,
        CustomerErrorCopy.message(error),
        haptic: false,
      );
    } finally {
      if (mounted) setState(() => _submittingInterest = false);
    }
  }

  Future<void> _startEnrollment(
    BuildContext context,
    WidgetRef ref,
    GoldenWishPlan plan,
  ) async {
    final kycStatus = ref.read(authControllerProvider).value?.user?.kycStatus;

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

    final scheme = GoldenWishSchemeType.fromApiValue(plan.schemeType);
    ref.read(goalCreateDraftStoreProvider.notifier).setScheme(scheme);
    context.push(AppRoutes.goalsCreateMoment);
  }
}
