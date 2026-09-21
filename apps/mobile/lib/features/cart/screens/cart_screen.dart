import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/editorial/editorial_panel.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../components/product/product_image_placeholder.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/cart.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_price_lock_banner.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, this.inTabShell = false});

  /// When true, omits the nested [Scaffold] — the tab shell provides chrome.
  final bool inTabShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final cart = ref.watch(cartSummaryProvider);

    final body = auth.when(
      data: (state) {
        if (state.step != AuthFlowStep.signedIn) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            headline: 'Your bag is empty',
            body: 'Sign in to add pieces and review current prices.',
            ctaLabel: 'Sign in',
            onCtaTap: () => context.push(
              Uri(
                path: AppRoutes.auth,
                queryParameters: {'from': AppRoutes.cart},
              ).toString(),
            ),
          );
        }

        return cart.when(
          data: (summary) {
            if (summary.items.isEmpty) {
              return EmptyState(
                icon: Icons.shopping_bag_outlined,
                headline: CustomerCopy.bagEmptyHeadline,
                body: CustomerCopy.bagEmptyBody,
                ctaLabel: CustomerCopy.bagEmptyCta,
                onCtaTap: () => context.go(AppRoutes.shop),
              );
            }

            return Column(
              children: [
                CartPriceLockBanner(summary: summary),
                if (inTabShell)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your bag',
                        style: AppTypography.displayItalic(28),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      inTabShell ? 0 : AppSpacing.screenPadding,
                      AppSpacing.screenPadding,
                      AppSpacing.screenPadding,
                    ),
                    itemCount: summary.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) => _CartLineCard(
                      item: summary.items[index],
                      onRemove: () => ref
                          .read(cartActionsProvider.notifier)
                          .removeProduct(summary.items[index].product.id),
                    ),
                  ),
                ),
                _CartFooter(summary: summary),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: LoadingShimmer(
              width: double.infinity,
              height: AppSpacing.x3l * 2,
            ),
          ),
          error: (error, _) => ErrorState(
            body: CustomerErrorCopy.message(error),
            onRetry: () => ref.invalidate(cartSummaryProvider),
          ),
        );
      },
      loading: () => const Center(
        child: LoadingShimmer(width: double.infinity, height: AppSpacing.x3l),
      ),
      error: (error, _) => ErrorState(body: CustomerErrorCopy.message(error)),
    );

    if (inTabShell) {
      return ColoredBox(color: AppColors.paper, child: body);
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'Bag'),
      body: body,
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.item, required this.onRemove});

  final CartLineItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return EditorialPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacing.x3l + AppSpacing.sm,
            height: AppSpacing.x3l + AppSpacing.sm,
            child: product.primaryImage == null
                ? const ProductImagePlaceholder()
                : CachedNetworkImage(
                    imageUrl: product.primaryImage!,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ProductImagePlaceholder(),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTypography.productName.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${product.purityDisplay} · ${product.weightDisplay}',
                  style: AppTypography.uiCaption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  product.price.totalDisplay,
                  style: AppTypography.priceMD.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!item.isAvailable) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.unavailableReason ?? 'Unavailable',
                    style: AppTypography.uiCaption.copyWith(
                      color: AppColors.blushClay,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Remove',
                style: AppTypography.uiMicro.copyWith(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartFooter extends ConsumerWidget {
  const _CartFooter({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnavailable = summary.items.any((item) => !item.isAvailable);
    final auth = ref.watch(authControllerProvider).value;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTypography.uiBodyMD),
              Text(summary.subtotalDisplay, style: AppTypography.priceMD),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: hasUnavailable
                ? 'Remove unavailable items'
                : 'Proceed to checkout',
            isFullWidth: true,
            isDisabled: hasUnavailable || summary.itemCount == 0,
            onTap: hasUnavailable
                ? null
                : () {
                    final user = auth?.user;
                    if (user == null) {
                      context.push(
                        Uri(
                          path: AppRoutes.auth,
                          queryParameters: {'from': AppRoutes.cart},
                        ).toString(),
                      );
                      return;
                    }

                    context.push(AppRoutes.checkout);
                  },
          ),
        ],
      ),
    );
  }
}
