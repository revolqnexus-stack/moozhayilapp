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
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/address.dart';
import '../../../core/models/gold_balance.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/indian_format.dart';
import '../../../core/kyc/kyc_gate_coordinator.dart';
import '../../../core/services/razorpay_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../my_gold/providers/gold_balance_provider.dart';
import '../../profile/providers/addresses_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/aura_mc_waiver_banner.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.redeemWithGold = false});

  final bool redeemWithGold;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

int _totalDuePaise({
  required int subtotalPaise,
  required bool useGoldBalance,
  required bool isCod,
  GoldBalance? balance,
}) {
  if (!useGoldBalance || isCod || balance == null) {
    return subtotalPaise;
  }

  final credit = balance.totalValuePaise.clamp(0, subtotalPaise);
  return subtotalPaise - credit;
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String _paymentMethod = 'upi';
  bool _useGoldBalance = false;
  bool _isPlacing = false;
  late final RazorpayCheckoutGateway _razorpayCheckout;

  @override
  void initState() {
    super.initState();
    _useGoldBalance = widget.redeemWithGold;
    _razorpayCheckout = RazorpayCheckout();
  }

  @override
  void dispose() {
    _razorpayCheckout.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartSummaryProvider).value;
    final addressId = _selectedAddressId;

    if (cart == null || cart.items.isEmpty || addressId == null) {
      return;
    }

    final usesGold =
        _useGoldBalance && _paymentMethod != 'cod';
    final kycGrossTotalPaise =
        cart.kycGrossTotalPaise ?? cart.subtotalPaise;
    final gateReason = checkoutKycReason(
      orderTotalPaise: kycGrossTotalPaise,
      usesGoldBalance: usesGold,
    );
    if (gateReason != null) {
      final allowed = await ensureKycAllowsAction(
        context: context,
        ref: ref,
        reason: gateReason,
        returnRoute: AppRoutes.checkout,
        orderTotalPaise: kycGrossTotalPaise,
        usesGoldBalance: usesGold,
      );
      if (!allowed || !mounted) return;
    }

    setState(() => _isPlacing = true);
    try {
      final items = cart.items
          .map(
            (item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            },
          )
          .toList();

      final method = _useGoldBalance && _paymentMethod != 'cod'
          ? 'gold_balance'
          : _paymentMethod;

      // Compute how many grams of gold balance to redeem (server validates
      // against the user's actual balance).
      String? useGoldBalanceGrams;
      if (_useGoldBalance && _paymentMethod != 'cod') {
        final balance = ref.read(goldBalanceProvider).value;
        if (balance != null) {
          final totalGrams = double.tryParse(balance.totalGrams) ?? 0;
          if (totalGrams > 0) {
            // Send the full balance and let the server cap it at order value.
            useGoldBalanceGrams = balance.totalGrams;
          }
        }
      }

      final response = await ref
          .read(orderActionsProvider.notifier)
          .placeOrder(
            items: items,
            deliveryAddressId: addressId,
            paymentMethod: method,
            useGoldBalanceGrams: useGoldBalanceGrams,
          );

      if (!mounted) {
        return;
      }

      if (response.paymentRequired) {
        final keyId = response.razorpayKeyId;
        final rzpOrderId = response.razorpayOrderId;
        final sessionId = response.paymentSessionId;

        if (keyId == null || rzpOrderId == null || sessionId == null) {
          showPremiumSnackBar(
            context,
            'Payment configuration error. Please contact support.',
            haptic: false,
          );
          return;
        }

        final captured = await ref
            .read(razorpayServiceProvider)
            .pay(
              context: context,
              checkout: _razorpayCheckout,
              keyId: keyId,
              razorpayOrderId: rzpOrderId,
              amountPaise: response.paymentAmountPaise,
              paymentSessionId: sessionId,
              description: 'Order ${response.order.orderNumber}',
            );

        if (!mounted || !captured) return;
      }

      context.go('/orders/confirmation/${response.order.id}');
    } catch (error) {
      if (!mounted) return;

      final kycGrossTotalPaise =
          cart.kycGrossTotalPaise ?? cart.subtotalPaise;
      final gateReason = checkoutKycReason(
        orderTotalPaise: kycGrossTotalPaise,
        usesGoldBalance: _useGoldBalance && _paymentMethod != 'cod',
      );
      if (gateReason != null &&
          await handleKycApiError(
            context: context,
            ref: ref,
            error: error,
            reason: gateReason,
            returnRoute: AppRoutes.checkout,
            orderTotalPaise: kycGrossTotalPaise,
            usesGoldBalance: _useGoldBalance && _paymentMethod != 'cod',
          )) {
        return;
      }

      showPremiumSnackBar(
        context,
        CustomerErrorCopy.message(error),
        haptic: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final cart = ref.watch(cartSummaryProvider);
    final addresses = ref.watch(userAddressesProvider);
    final goldBalance = ref.watch(goldBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'Checkout'),
      body: auth.when(
        data: (state) {
          if (state.step != AuthFlowStep.signedIn) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              headline: 'Checkout',
              body: 'Sign in to complete your order.',
              ctaLabel: 'Sign in',
              onCtaTap: () => context.push(
                Uri(
                  path: AppRoutes.auth,
                  queryParameters: {'from': AppRoutes.checkout},
                ).toString(),
              ),
            );
          }

          return cart.when(
            data: (summary) {
              if (summary.items.isEmpty) {
                return EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  headline: 'Nothing to checkout',
                  body: 'Add items to your cart first.',
                  ctaLabel: 'Browse Shop',
                  onCtaTap: () => context.go(AppRoutes.shop),
                );
              }

              return addresses.when(
                data: (addressList) {
                  if (_selectedAddressId == null && addressList.isNotEmpty) {
                    final defaultAddress = addressList
                        .where((address) => address.isDefault)
                        .map((address) => address.id)
                        .firstOrNull;
                    _selectedAddressId = defaultAddress ?? addressList.first.id;
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(
                            AppSpacing.screenPadding,
                          ),
                          children: [
                            Text(
                              'Order summary',
                              style: AppTypography.headingSM,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...summary.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.product.name} × ${item.quantity}',
                                        style: AppTypography.uiBodySM,
                                      ),
                                    ),
                                    Text(
                                      item.product.price.totalDisplay,
                                      style: AppTypography.uiBodySM,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: AppColors.border),
                            AuraMcWaiverBanner(
                              usingGoldBalance:
                                  _useGoldBalance && _paymentMethod != 'cod',
                            ),
                            Text(
                              'Delivery address',
                              style: AppTypography.headingSM,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            if (addressList.isEmpty)
                              Text(
                                'Add an address in Profile before checkout.',
                                style: AppTypography.uiBodySM,
                              )
                            else
                              Column(
                                children: [
                                  ...addressList.map(
                                    (address) => _AddressOption(
                                      address: address,
                                      selected:
                                          _selectedAddressId == address.id,
                                      onTap: () => setState(
                                        () =>
                                            _selectedAddressId = address.id,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: AppSpacing.lg),
                            Text('Payment', style: AppTypography.headingSM),
                            const SizedBox(height: AppSpacing.sm),
                            Column(
                              children: [
                                _PaymentOption(
                                  label: 'UPI / Card',
                                  value: 'upi',
                                  groupValue: _paymentMethod,
                                  onChanged: (value) => setState(() {
                                    if (value == null) return;
                                    _paymentMethod = value;
                                  }),
                                ),
                                _PaymentOption(
                                  label: 'Cash on delivery',
                                  value: 'cod',
                                  groupValue: _paymentMethod,
                                  onChanged: (value) => setState(() {
                                    if (value == null) return;
                                    _paymentMethod = value;
                                    _useGoldBalance = false;
                                  }),
                                ),
                              ],
                            ),
                            goldBalance.when(
                              data: (balance) {
                                final grams =
                                    double.tryParse(balance.totalGrams) ?? 0;
                                if (grams <= 0) {
                                  return const SizedBox.shrink();
                                }

                                return SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'Pay with My Gold (${balance.totalGramsDisplay})',
                                    style: AppTypography.uiBodyMD,
                                  ),
                                  value: _useGoldBalance,
                                  onChanged: _paymentMethod == 'cod'
                                      ? null
                                      : (value) => setState(
                                          () => _useGoldBalance = value,
                                        ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal', style: AppTypography.uiBodyMD),
                                Text(
                                  summary.subtotalDisplay,
                                  style: AppTypography.uiBodyMD,
                                ),
                              ],
                            ),
                            if (_useGoldBalance && _paymentMethod != 'cod') ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Aura making-charge savings (if eligible) apply at order placement.',
                                style: AppTypography.uiCaption.copyWith(
                                  color: AppColors.slateMist,
                                ),
                              ),
                            ],
                            goldBalance.maybeWhen(
                              data: (balance) {
                                if (!_useGoldBalance ||
                                    _paymentMethod == 'cod') {
                                  return const SizedBox.shrink();
                                }

                                final credit = balance.totalValuePaise.clamp(
                                  0,
                                  summary.subtotalPaise,
                                );
                                if (credit <= 0) {
                                  return const SizedBox.shrink();
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.xs,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'My Gold applied',
                                        style: AppTypography.uiBodyMD.copyWith(
                                          color: AppColors.gold,
                                        ),
                                      ),
                                      Text(
                                        '-${IndianFormat.formatInrPaise(credit)}',
                                        style: AppTypography.priceTabular.copyWith(
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              orElse: () => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            goldBalance.maybeWhen(
                              data: (balance) {
                                final totalDue = _totalDuePaise(
                                  subtotalPaise: summary.subtotalPaise,
                                  useGoldBalance: _useGoldBalance,
                                  isCod: _paymentMethod == 'cod',
                                  balance: balance,
                                );

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total due',
                                      style: AppTypography.headingSM,
                                    ),
                                    Text(
                                      IndianFormat.formatInrPaise(totalDue),
                                      style: AppTypography.priceTabular.copyWith(
                                        fontSize: AppTypography.priceMD.fontSize,
                                        fontWeight: AppTypography.priceMD.fontWeight,
                                        color: AppTypography.priceMD.color,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              orElse: () => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total due',
                                    style: AppTypography.headingSM,
                                  ),
                                  Text(
                                    summary.subtotalDisplay,
                                    style: AppTypography.priceMD,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        decoration: const BoxDecoration(
                          color: AppColors.paper,
                          border: Border(
                            top: BorderSide(
                              color: AppColors.borderStrong,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: PrimaryButton(
                          label: _isPlacing ? 'Placing order…' : 'Place order',
                          isFullWidth: true,
                          isDisabled:
                              _isPlacing ||
                              _selectedAddressId == null ||
                              addressList.isEmpty,
                          onTap: _isPlacing || _selectedAddressId == null
                              ? null
                              : _placeOrder,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    ErrorState(body: CustomerErrorCopy.message(error)),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(body: CustomerErrorCopy.message(error)),
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  const _AddressOption({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final UserAddress address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.borderStrong,
            width: 0.5,
          ),
        ),
        child: RadioListTile<String>(
          value: address.id,
          groupValue: selected ? address.id : null,
          onChanged: (_) => onTap(),
          title: Text(address.fullName, style: AppTypography.uiBodyMD),
          subtitle: Text(
            '${address.line1}, ${address.city} ${address.pincode}',
            style: AppTypography.uiCaption,
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTypography.uiBodyMD),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
