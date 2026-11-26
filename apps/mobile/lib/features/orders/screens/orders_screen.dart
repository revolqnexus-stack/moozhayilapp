import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../components/editorial/editorial_panel.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/order.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final orders = ref.watch(ordersListProvider());

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'My Orders'),
      body: auth.when(
        data: (state) {
          if (state.step != AuthFlowStep.signedIn) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              headline: 'No orders yet',
              body: 'Sign in to view your order history.',
              ctaLabel: 'Sign in',
              onCtaTap: () => context.push(
                Uri(
                  path: AppRoutes.auth,
                  queryParameters: {'from': AppRoutes.orders},
                ).toString(),
              ),
            );
          }

          return orders.when(
            data: (response) {
              if (response.data.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  headline: CustomerCopy.ordersEmptyHeadline,
                  body: CustomerCopy.ordersEmptyBody,
                  ctaLabel: 'Explore Jewellery',
                  onCtaTap: () => context.go(AppRoutes.shop),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(ordersListProvider());
                  await ref.read(ordersListProvider().future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: response.data.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _OrderCard(
                    order: response.data[index],
                    onTap: () =>
                        context.push('/orders/${response.data[index].id}'),
                  ),
                ),
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
              onRetry: () => ref.invalidate(ordersListProvider()),
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LoadingShimmer(
            width: double.infinity,
            height: AppSpacing.x3l * 2,
          ),
        ),
        error: (error, _) => ErrorState(body: CustomerErrorCopy.message(error)),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EditorialPanel(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderNumber, style: AppTypography.uiBodyMD),
              Text(
                order.statusDisplay,
                style: AppTypography.uiCaption.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            order.totalDisplay,
            style: AppTypography.priceMD.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
            style: AppTypography.uiCaption,
          ),
        ],
      ),
    );
  }
}
