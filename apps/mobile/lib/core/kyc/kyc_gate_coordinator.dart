import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/widgets/kyc_gate_bottom_sheet.dart';
import '../services/api_service.dart';
export 'decide_kyc_gate.dart';

/// Refetches KYC status (shimmer sheet) and blocks with gate UI when needed.
Future<bool> ensureKycAllowsAction({
  required BuildContext context,
  required WidgetRef ref,
  required KycGateReason reason,
  required String returnRoute,
  int? orderTotalPaise,
  bool usesGoldBalance = false,
  int? contributionAmountPaise,
}) {
  return showKycGateFlow(
    context: context,
    ref: ref,
    reason: reason,
    returnRoute: returnRoute,
    orderTotalPaise: orderTotalPaise,
    usesGoldBalance: usesGoldBalance,
    contributionAmountPaise: contributionAmountPaise,
  );
}

Future<bool> handleKycApiError({
  required BuildContext context,
  required WidgetRef ref,
  required Object error,
  required KycGateReason reason,
  required String returnRoute,
  int? orderTotalPaise,
  bool usesGoldBalance = false,
}) async {
  if (error is ApiException && error.code == 'KYC_REQUIRED') {
    return ensureKycAllowsAction(
      context: context,
      ref: ref,
      reason: reason,
      returnRoute: returnRoute,
      orderTotalPaise: orderTotalPaise,
      usesGoldBalance: usesGoldBalance,
    );
  }
  return false;
}
