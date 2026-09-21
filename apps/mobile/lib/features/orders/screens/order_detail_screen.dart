import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/buttons/destructive_button.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/indian_format.dart';
import '../providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppTopBar.detail(title: 'Order Details'),
      body: order.when(
        data: (response) {
          final data = response.order;
          final canCancel =
              data.status == 'confirmed' || data.status == 'pending_payment';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text(data.orderNumber, style: AppTypography.headingSM),
              const SizedBox(height: AppSpacing.xxs),
              Text(data.statusDisplay, style: AppTypography.uiBodyMD),
              const SizedBox(height: AppSpacing.lg),
              Text('Items', style: AppTypography.headingSM),
              const SizedBox(height: AppSpacing.sm),
              ...data.items.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.smokeLine),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: AppTypography.uiBodyMD,
                        ),
                      ),
                      Text(item.unitPriceDisplay, style: AppTypography.priceMD),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Payment', style: AppTypography.headingSM),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(label: 'Total', value: data.totalDisplay),
              if (response.paymentBreakdown.goldAppliedPaise > 0)
                _SummaryRow(
                  label: 'Gold applied',
                  value: IndianFormat.formatInrPaise(
                    response.paymentBreakdown.goldAppliedPaise,
                  ),
                ),
              if (response.paymentBreakdown.cashPaidPaise > 0)
                _SummaryRow(
                  label: 'Cash paid',
                  value: IndianFormat.formatInrPaise(
                    response.paymentBreakdown.cashPaidPaise,
                  ),
                ),
              if (canCancel) ...[
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: DestructiveButton(
                    label: 'Cancel order',
                    onTap: () async {
                      await ref
                          .read(orderActionsProvider.notifier)
                          .cancelOrder(orderId, 'Cancelled by customer');
                      if (context.mounted) {
                        showPremiumSnackBar(context, 'Order cancelled');
                      }
                    },
                  ),
                ),
              ],
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
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.uiBodyMD),
          Text(value, style: AppTypography.priceMD),
        ],
      ),
    );
  }
}
