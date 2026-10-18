import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../components/overlays/confirmation_bottom_sheet.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/vault_item.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/vault_list_display.dart';
import '../providers/vault_product_ids_display.dart';
import '../providers/vault_provider.dart';
import '../widgets/dream_vault_card.dart';
import '../widgets/goal_start_bottom_sheet.dart';

class DreamVaultScreen extends ConsumerWidget {
  const DreamVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final vault = ref.watch(vaultDisplayItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'Dream Vault'),
      body: auth.when(
        data: (state) {
          if (state.step != AuthFlowStep.signedIn) {
            return EmptyState(
              icon: Icons.auto_awesome_outlined,
              headline: CustomerCopy.dreamVaultSignedOutHeadline,
              body: 'Sign in to save pieces and track your progress.',
              ctaLabel: 'Sign in',
              onCtaTap: () => context.push(
                Uri(
                  path: AppRoutes.auth,
                  queryParameters: {'from': AppRoutes.dreamVault},
                ).toString(),
              ),
            );
          }

          return vault.when(
            data: (response) {
              if (response.items.isEmpty) {
                return EmptyState(
                  icon: Icons.auto_awesome_outlined,
                  headline: CustomerCopy.dreamVaultEmptyHeadline,
                  body: CustomerCopy.dreamVaultEmptyBody,
                  ctaLabel: CustomerCopy.dreamVaultEmptyCta,
                  onCtaTap: () => context.go(AppRoutes.shop),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                itemCount: response.items.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const _DreamVaultIntro();
                  }
                  final item = response.items[index - 1];
                  return DreamVaultCard(
                    item: item,
                    onStartGoalTap: () => showGoalStartBottomSheet(
                      context: context,
                      ref: ref,
                      item: item,
                    ),
                    onRemoveTap: () => _confirmRemove(context, ref, item),
                    onViewGoalTap: () => context.push(AppRoutes.myPlans),
                  );
                },
              );
            },
            loading: () => ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, _) => const LoadingShimmer(
                width: double.infinity,
                height: AppSpacing.x3l * 3,
              ),
            ),
            error: (error, _) => ErrorState(
              body: CustomerErrorCopy.message(error),
              onRetry: () => ref.invalidate(vaultItemsProvider),
            ),
          );
        },
        loading: () => const Center(
          child: LoadingShimmer(width: double.infinity, height: AppSpacing.x3l),
        ),
        error: (error, _) => ErrorState(body: CustomerErrorCopy.message(error)),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    VaultItem item,
  ) async {
    await showConfirmationSheet(
      context: context,
      title: 'Remove from Vault',
      body: 'This piece will be removed from your Dream Vault.',
      confirmLabel: 'Remove',
      cancelLabel: 'Keep it',
      isDestructive: true,
      onConfirm: () async {
        await ref
            .read(vaultActionsProvider.notifier)
            .removeProduct(item.product.id);
        forgetVaultProductInCache(ref, item.product.id);
        applyOptimisticVaultToggle(
          ref,
          productId: item.product.id,
          saving: false,
        );
      },
    );
  }
}

class _DreamVaultIntro extends StatelessWidget {
  const _DreamVaultIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.burgundyDeep,
        border: Border(left: BorderSide(color: AppColors.gold, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CustomerCopy.dreamVaultTitle.toUpperCase(),
            style: AppTypography.uiMicro.copyWith(
              color: AppColors.goldLight,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pieces you\u2019re saving toward',
            style: AppTypography.headingSM.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Every saved piece can become a Schemes plan or a purchase when your gold is ready.',
            style: AppTypography.uiBodySM.copyWith(
              color: AppColors.cream.withValues(alpha: 0.72),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
