import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/buttons/primary_button.dart';

import '../../../components/feedback/premium_snackbar.dart';
import '../../../components/navigation/top_app_bar.dart';

import '../../../core/animations/luxury_success.dart';

import '../../../core/constants/colors.dart';

import '../../../core/constants/customer_copy.dart';

import '../../../core/constants/spacing.dart';

import '../../../core/constants/typography.dart';

import '../../../core/services/razorpay_service.dart';
import '../../../core/utils/indian_format.dart';

import '../../../core/utils/app_haptics.dart';

import '../../goals/providers/goals_provider.dart';

import '../../my_gold/providers/gold_balance_provider.dart';

class ContributeScreen extends ConsumerStatefulWidget {
  const ContributeScreen({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends ConsumerState<ContributeScreen> {
  var _amountPaise = 300000;

  var _submitting = false;

  late final RazorpayCheckout _razorpayCheckout;

  @override
  void initState() {
    super.initState();

    _razorpayCheckout = RazorpayCheckout();
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

        subtitle: CustomerCopy.contributionMovingForward,

        onDone: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  Future<void> _submit() async {
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

        final captured = await ref
            .read(razorpayServiceProvider)
            .pay(
              context: context,

              checkout: _razorpayCheckout,

              keyId: keyId,

              razorpayOrderId: rzpOrderId,

              amountPaise: result.contribution.amountPaise,

              paymentSessionId: sessionId,

              description: 'Gold contribution',
            );

        if (!mounted || !captured) return;
      }

      AppHaptics.light();

      await _showContributionSuccess(result.contribution.amountDisplay);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      showPremiumSnackBar(context, CustomerCopy.paymentError, haptic: false);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountLabel = IndianFormat.formatInrPaise(_amountPaise);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,

      appBar: AppTopBar.detail(title: 'Contribute'),

      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Text('Contribution amount', style: AppTypography.headingMD),

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

            const Spacer(),

            PrimaryButton(
              label: _submitting ? 'Processing…' : 'Contribute now',

              onTap: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
