import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/payments_provider.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final _upiController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _addUpi() async {
    final upiId = _upiController.text.trim();
    if (upiId.isEmpty) {
      return;
    }

    setState(() => _isAdding = true);
    try {
      final verified = await ref
          .read(paymentMethodActionsProvider.notifier)
          .verifyUpi(upiId);
      await ref
          .read(paymentMethodActionsProvider.notifier)
          .addUpi(upiId: upiId, displayLabel: verified.displayLabel);
      _upiController.clear();
      if (mounted) {
        showPremiumSnackBar(context, 'Payment method added');
      }
    } catch (error) {
      if (mounted) {
        showPremiumSnackBar(
          context,
          CustomerErrorCopy.message(error),
          haptic: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final methods = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'Payment Methods'),
      body: auth.when(
        data: (state) {
          if (state.step != AuthFlowStep.signedIn) {
            return EmptyState(
              icon: Icons.payment_outlined,
              headline: 'Payment methods',
              body: 'Sign in to manage UPI and cards.',
              ctaLabel: 'Sign in',
              onCtaTap: () => context.push(
                Uri(
                  path: AppRoutes.auth,
                  queryParameters: {'from': AppRoutes.profilePaymentMethods},
                ).toString(),
              ),
            );
          }

          return methods.when(
            data: (items) => ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text('Saved methods', style: AppTypography.headingSM),
                const SizedBox(height: AppSpacing.sm),
                if (items.isEmpty)
                  const EmptyState(
                    headline: 'No saved payment methods.',
                    body: 'Add UPI below, or save a method during checkout.',
                  )
                else
                  ...items.map(
                    (method) => _MethodTile(
                      method: method,
                      onDelete: () => ref
                          .read(paymentMethodActionsProvider.notifier)
                          .removeMethod(method.id),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text('Add UPI', style: AppTypography.headingSM),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _upiController,
                  decoration: InputDecoration(
                    hintText: 'name@upi',
                    filled: true,
                    fillColor: AppColors.pureWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.smokeLine),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: _isAdding ? 'Adding…' : 'Add UPI',
                  isFullWidth: true,
                  isDisabled: _isAdding,
                  onTap: _isAdding ? null : _addUpi,
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: LoadingShimmer(
                width: double.infinity,
                height: AppSpacing.x3l,
              ),
            ),
            error: (error, _) => ErrorState(
              body: CustomerErrorCopy.message(error),
              onRetry: () => ref.invalidate(paymentMethodsProvider),
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LoadingShimmer(width: double.infinity, height: AppSpacing.x3l),
        ),
        error: (error, _) => ErrorState(body: CustomerErrorCopy.message(error)),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method, required this.onDelete});

  final PaymentMethod method;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.smokeLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.displayLabel, style: AppTypography.uiBodyMD),
                if (method.isDefault)
                  Text(
                    'Default',
                    style: AppTypography.uiCaption.copyWith(
                      color: AppColors.antiqueGold,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
