import 'package:flutter/material.dart';

import '../../components/buttons/primary_button.dart';
import '../constants/colors.dart';
import '../constants/customer_copy.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

class PriceBreakdownSheet extends StatelessWidget {
  const PriceBreakdownSheet({
    super.key,
    required this.oldTotalDisplay,
    required this.newTotalDisplay,
    required this.onConfirm,
  });

  final String oldTotalDisplay;
  final String newTotalDisplay;
  final VoidCallback onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required String oldTotalDisplay,
    required String newTotalDisplay,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      builder: (context) => PriceBreakdownSheet(
        oldTotalDisplay: oldTotalDisplay,
        newTotalDisplay: newTotalDisplay,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CustomerCopy.priceLockChangedTitle,
            style: AppTypography.headingMD,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CustomerCopy.priceLockChangedBody,
            style: AppTypography.uiBodyMD.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Row(
            label: CustomerCopy.priceLockPreviousTotal,
            value: oldTotalDisplay,
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: CustomerCopy.priceLockUpdatedTotal,
            value: newTotalDisplay,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: CustomerCopy.priceLockConfirmPay,
            isFullWidth: true,
            onTap: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.uiBodySM),
        Text(
          value,
          style: AppTypography.priceTabular.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
