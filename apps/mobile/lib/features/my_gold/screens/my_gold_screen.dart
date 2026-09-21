import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/cards/product_card.dart';
import '../../../components/editorial/section_header.dart';
import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../core/utils/customer_error_copy.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../vault/widgets/vault_aware_product_card.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/time/server_clock_provider.dart';
import '../providers/gold_balance_provider.dart';
import '../widgets/gold_ledger.dart';
import '../../../core/kyc/kyc_gate_coordinator.dart';
import '../../profile/providers/kyc_provider.dart';
import '../widgets/kyc_redemption_panel.dart';
import '../widgets/my_gold_hero.dart';

class MyGoldScreen extends ConsumerWidget {
  const MyGoldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    final balance = ref.watch(goldBalanceProvider);
    final clock = ref.watch(serverClockProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final ledger = ref.watch(goldLedgerProvider);
    final redeemable = ref.watch(redeemableProductsProvider);
    final kyc = ref.watch(kycStatusProvider);
    final KycGateBlock? redemptionBlock = kyc.maybeWhen(
      data: (status) {
        final decision = decideKycGate(
          kycStatus: status.kycStatus,
          reason: KycGateReason.redemption,
        );
        return decision is KycGateBlock ? decision : null;
      },
      orElse: () => null,
    );
    final redemptionBlocked = redemptionBlock != null;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'My Gold'),
      body: balance.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(goldBalanceProvider);
            ref.invalidate(goldLedgerProvider);
            ref.invalidate(redeemableProductsProvider);
            await ref.read(goldBalanceProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.x3l,
            ),
            children: [
              MyGoldHero(
                balance: data,
                clock: clock,
                isOffline: isOffline,
                isRefreshing: balance.isLoading && balance.hasValue,
                isLoading: balance.isLoading,
                onStaleRefresh: () => ref.invalidate(goldBalanceProvider),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeader(
                eyebrow: 'Every gram counts',
                title: 'Your activity',
              ),
              const SizedBox(height: AppSpacing.md),
              ledger.when(
                data: (entries) => GoldLedgerList(entries: entries.data),
                loading: () =>
                    const LoadingShimmer(width: double.infinity, height: 120),
                error: (error, _) => ErrorState(
                  body: CustomerErrorCopy.message(error),
                  onRetry: () => ref.invalidate(goldLedgerProvider),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeader(
                eyebrow: 'Within reach',
                title: 'Ready to redeem',
              ),
              const SizedBox(height: AppSpacing.md),
              redeemable.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Text(
                      'Keep saving — your first redeemable piece is within reach.',
                      style: AppTypography.auraVoice.copyWith(
                        color: AppColors.slateMist,
                      ),
                    );
                  }

                  return SizedBox(
                    height: AppSpacing.x3l * 5,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: products.length > 6 ? 6 : products.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) => VaultAwareProductCard(
                        product: products[index],
                        variant: ProductCardVariant.horizontal,
                      ),
                    ),
                  );
                },
                loading: () =>
                    const LoadingShimmer(width: double.infinity, height: 80),
                error: (_, _) => const SizedBox.shrink(),
              ),
              if (redemptionBlock != null) ...[
                const SizedBox(height: AppSpacing.lg),
                KycRedemptionPanel(
                  block: redemptionBlock,
                  isLoading: kyc.isLoading,
                  returnRoute: AppRoutes.myGold,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: redemptionBlocked
                    ? null
                    : () {
                        if (user == null) {
                          context.push(
                            Uri(
                              path: AppRoutes.auth,
                              queryParameters: {'from': AppRoutes.myGoldRedeem},
                            ).toString(),
                          );
                          return;
                        }

                        context.push(AppRoutes.myGoldRedeem);
                      },
                child: const Text('Browse all redeemable pieces'),
              ),
            ],
          ),
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LoadingShimmer(width: double.infinity, height: 200),
        ),
        error: (error, _) => ErrorState(
          headline: 'We couldn\u2019t load your gold balance.',
          body: 'Try again in a moment.',
          onRetry: () => ref.invalidate(goldBalanceProvider),
        ),
      ),
    );
  }
}

class RedeemScreen extends ConsumerWidget {
  const RedeemScreen({super.key});

  Future<void> _redeemProduct(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) async {
    final allowed = await ensureKycAllowsAction(
      context: context,
      ref: ref,
      reason: KycGateReason.redemption,
      returnRoute: AppRoutes.myGoldRedeem,
      usesGoldBalance: true,
    );
    if (!allowed || !context.mounted) return;

    try {
      await ref.read(cartActionsProvider.notifier).addProduct(productId);
      if (context.mounted) {
        context.push('${AppRoutes.checkout}?redeem=1');
      }
    } catch (error) {
      if (context.mounted) {
        showPremiumSnackBar(
          context,
          CustomerErrorCopy.message(error),
          haptic: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redeemable = ref.watch(redeemableProductsProvider);
    final kyc = ref.watch(kycStatusProvider);
    final KycGateBlock? redemptionBlock = kyc.maybeWhen(
      data: (status) {
        final decision = decideKycGate(
          kycStatus: status.kycStatus,
          reason: KycGateReason.redemption,
        );
        return decision is KycGateBlock ? decision : null;
      },
      orElse: () => null,
    );
    final redemptionBlocked = redemptionBlock != null;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'Redeem Gold'),
      body: redeemable.when(
        data: (products) {
          if (products.isEmpty) {
            return const EmptyState(
              icon: Icons.diamond_outlined,
              headline: 'Not enough gold yet',
              body: 'Keep contributing to unlock redeemable jewellery.',
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redeem with My Gold',
                        style: AppTypography.displayItalic(28),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${products.length} pieces within your balance. '
                        'Tap a piece to redeem with My Gold.',
                        style: AppTypography.uiBodySM.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (redemptionBlock != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        KycRedemptionPanel(
                          block: redemptionBlock,
                          isLoading: kyc.isLoading,
                          returnRoute: AppRoutes.myGoldRedeem,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                sliver: SliverList.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => VaultAwareProductCard(
                    product: products[index],
                    variant: ProductCardVariant.horizontal,
                    onTap: redemptionBlocked
                        ? null
                        : () =>
                            _redeemProduct(context, ref, products[index].id),
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.x3l),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LoadingShimmer(width: double.infinity, height: 200),
        ),
        error: (error, _) => ErrorState(
          body: CustomerErrorCopy.message(error),
          onRetry: () => ref.invalidate(redeemableProductsProvider),
        ),
      ),
    );
  }
}
