import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/animations/luxury_success.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/orders_provider.dart';
import '../utils/order_timeline_mapper.dart';

/// Order confirmation screen.
///
/// Luxury motion layer:
///   On first load (data arrives) the screen shows [LuxurySuccessOverlay]
///   instead of an immediate icon — a calm, dark success sequence
///   (ring expand → checkmark → copy → auto-dismiss after ≈ 3 s).
///   After the overlay completes the normal order detail is shown.
///
///   Business logic, providers, and routes are unchanged.
class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  /// Whether the luxury success overlay should still be displayed.
  bool _showSuccess = true;

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderDetailProvider(widget.orderId));

    // ── Success overlay phase ─────────────────────────────────────────────
    if (_showSuccess) {
      return order.when(
        data: (response) {
          if (!orderQualifiesForSuccessCelebration(response.order.status)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.invalidate(orderDetailProvider(widget.orderId));
              if (mounted) setState(() => _showSuccess = false);
            });
            return const Scaffold(
              backgroundColor: AppColors.warmIvory,
              body: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.antiqueGold,
                  ),
                ),
              ),
            );
          }

          return LuxurySuccessOverlay(
            title: 'Your order is confirmed.',
            subtitle:
                'We\u2019ll prepare your piece with care.\nYour showroom team will keep you updated.',
            detailLine: 'Order ${response.order.orderNumber}',
            majorSuccess: true,
            primaryActionLabel: 'View Order',
            onPrimaryAction: () => context.go('/orders/${widget.orderId}'),
            secondaryActionLabel: 'Continue Shopping',
            onSecondaryAction: () => context.go(AppRoutes.shop),
            onDone: () {
              if (mounted) setState(() => _showSuccess = false);
            },
          );
        },
        loading: () => const Scaffold(
          backgroundColor: AppColors.warmIvory,
          body: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.antiqueGold,
              ),
            ),
          ),
        ),
        error: (_, _) {
          // On error skip success and fall through to the detail screen.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showSuccess = false);
          });
          return const SizedBox.shrink();
        },
      );
    }

    // ── Order detail phase ────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppTopBar.detail(title: 'Order Confirmed'),
      body: order.when(
        data: (response) {
          final data = response.order;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 72,
                  color: AppColors.antiqueGold,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Thank you.',
                  style: AppTypography.headingLG,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Order ${data.orderNumber} is ${data.statusDisplay.toLowerCase()}.',
                  style: AppTypography.uiBodyMD,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  data.totalDisplay,
                  style: AppTypography.priceLG,
                  textAlign: TextAlign.center,
                ),
                if (data.makingChargeWaiverDisplay != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Aura making-charge savings: ${data.makingChargeWaiverDisplay}',
                    style: AppTypography.uiBodySM.copyWith(
                      color: AppColors.antiqueGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(),
                PrimaryButton(
                  label: 'View order',
                  isFullWidth: true,
                  onTap: () => context.go('/orders/${widget.orderId}'),
                ),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(
                  label: 'Continue shopping',
                  isFullWidth: true,
                  onTap: () => context.go(AppRoutes.shop),
                ),
              ],
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
        error: (_, _) => ErrorState(
          headline: 'We couldn\u2019t load your order.',
          body: 'Please try again in a moment.',
          onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId)),
        ),
      ),
    );
  }
}
