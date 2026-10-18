import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import 'payment_processing_animation.dart';

/// Non-blocking overlay shown only while the server verifies a Razorpay payment.
///
/// Never shown during the native Razorpay checkout sheet — only after it closes.
Future<T> withPaymentVerifyingOverlay<T>(
  BuildContext context,
  Future<T> Function() action,
) async {
  if (!context.mounted) {
    return action();
  }

  final navigator = Navigator.of(context, rootNavigator: true);
  var dismissed = false;

  void dismiss() {
    if (dismissed) return;
    dismissed = true;
    if (navigator.mounted) {
      navigator.pop();
    }
  }

  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: AppColors.ink.withValues(alpha: 0.55),
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.smokeLine),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PaymentProcessingAnimation(size: 72),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Verifying payment',
                    style: AppTypography.headingSM,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Please wait a moment while we confirm with your bank.',
                    style: AppTypography.uiBodySM.copyWith(
                      color: AppColors.slateMist,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  try {
    return await action();
  } finally {
    dismiss();
  }
}
