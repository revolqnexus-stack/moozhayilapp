import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/animations/luxury_success.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/kyc/kyc_gate_coordinator.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/razorpay_service.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/indian_format.dart';
import '../providers/goal_create_provider.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_enrollment_step_header.dart';
import '../../my_gold/providers/gold_balance_provider.dart';

class ContributeScreen extends ConsumerStatefulWidget {
  const ContributeScreen({
    super.key,
    required this.goalId,
    this.firstPayment = false,
    this.lockedAmountPaise,
  });

  final String goalId;
  final bool firstPayment;
  final int? lockedAmountPaise;

  @override
  ConsumerState<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends ConsumerState<ContributeScreen> {
  var _amountPaise = 300000;
  var _submitting = false;
  late final RazorpayCheckoutGateway _razorpayCheckout;

  bool get _isFirstPayment => widget.firstPayment;

  @override
  void initState() {
    super.initState();
    _razorpayCheckout = RazorpayCheckout();
    final locked = widget.lockedAmountPaise;
    if (_isFirstPayment && locked != null && locked > 0) {
      _amountPaise = locked;
    }
  }

  @override
  void dispose() {
    _razorpayCheckout.dispose();
    super.dispose();
  }

  Future<void> _showContributionSuccess(String amountDisplay) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.warmIvory,
      builder: (dialogContext) => LuxurySuccessOverlay(
        title: amountDisplay,
        subtitle: _isFirstPayment
            ? CustomerCopy.firstPaymentSuccessSubtitle
            : CustomerCopy.contributionMovingForward,
        onDone: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  Future<void> _submit() async {
    final allowed = await ensureKycAllowsAction(
      context: context,
      ref: ref,
      reason: KycGateReason.contribution,
      returnRoute: AppRoutes.goalContribute.replaceFirst(':goalId', widget.goalId),
      contributionAmountPaise: _amountPaise,
    );
    if (!allowed || !mounted) return;

    setState(() => _submitting = true);

    try {
      final result = await ref
          .read(goalsRepositoryProvider)
          .contribute(goalId: widget.goalId, amountPaise: _amountPaise);

      ref.invalidate(goalDetailProvider(widget.goalId));
      ref.invalidate(goalsListProvider);
      ref.invalidate(goldBalanceProvider);

      if (!mounted) return;

      if (result.paymentRequired) {
        final keyId = result.razorpayKeyId;
        final rzpOrderId = result.razorpayOrderId;
        final sessionId = result.paymentSessionId;

        if (keyId == null || rzpOrderId == null || sessionId == null) {
          showPremiumSnackBar(
            context,
            'Payment configuration error. Please contact support.',
            haptic: false,
          );
          return;
        }

        final captured = await ref.read(razorpayServiceProvider).pay(
              context: context,
              checkout: _razorpayCheckout,
              keyId: keyId,
              razorpayOrderId: rzpOrderId,
              amountPaise: result.contribution.amountPaise,
              paymentSessionId: sessionId,
              description: _isFirstPayment
                  ? 'Scheme booking advance'
                  : 'Gold contribution',
            );

        if (!mounted || !captured) return;
      }

      AppHaptics.light();
      await _showContributionSuccess(result.contribution.amountDisplay);

      if (!mounted) return;

      if (_isFirstPayment) {
        context.go(AppRoutes.myPlans);
      } else {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;

      if (await handleKycApiError(
        context: context,
        ref: ref,
        error: error,
        reason: KycGateReason.contribution,
        returnRoute:
            AppRoutes.goalContribute.replaceFirst(':goalId', widget.goalId),
      )) {
        return;
      }

      if (mounted) {
        showPremiumSnackBar(context, CustomerCopy.paymentError, haptic: false);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _firstPaymentTitle(GoldenWishSchemeType? scheme) {
    if (scheme == null) {
      return CustomerCopy.firstPaymentSecureBooking;
    }
    return scheme.isRateProtected
        ? CustomerCopy.firstPaymentSecureRate
        : CustomerCopy.firstPaymentSecureBooking;
  }

  @override
  Widget build(BuildContext context) {
    final amountLabel = IndianFormat.formatInrPaise(_amountPaise);
    final goalAsync = _isFirstPayment
        ? ref.watch(goalDetailProvider(widget.goalId))
        : null;
    final scheme = goalAsync?.value?.goal.schemeType;
    final schemeType = scheme == null
        ? null
        : GoldenWishSchemeType.fromApiValue(scheme);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppTopBar.detail(
        title: _isFirstPayment ? 'Secure your booking' : 'Contribute',
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isFirstPayment)
              GoalEnrollmentStepHeader(
                step: GoalEnrollmentStep.firstPayment,
                title: _firstPaymentTitle(schemeType),
                subtitle: CustomerCopy.firstPaymentBody,
              )
            else
              Text('Contribution amount', style: AppTypography.headingMD),
            const SizedBox(height: AppSpacing.lg),
            if (!_isFirstPayment)
              Slider(
                value: (_amountPaise ~/ 100).toDouble().clamp(1000, 50000),
                min: 1000,
                max: 50000,
                divisions: 49,
                label: amountLabel,
                onChanged: (value) =>
                    setState(() => _amountPaise = value.round() * 100),
              ),
            Text(
              amountLabel,
              style: AppTypography.priceTabular.copyWith(
                fontSize: AppTypography.headingSM.fontSize,
                fontWeight: FontWeight.w400,
                fontFamily: AppTypography.headingSM.fontFamily,
              ),
            ),
            if (_isFirstPayment) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                CustomerCopy.firstPaymentLockedAmount,
                style: AppTypography.uiBodySM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const Spacer(),
            PrimaryButton(
              label: _submitting
                  ? 'Processing…'
                  : (_isFirstPayment ? 'Pay now' : 'Contribute now'),
              onTap: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
