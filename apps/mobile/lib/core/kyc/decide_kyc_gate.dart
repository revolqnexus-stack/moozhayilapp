import '../constants/kyc_thresholds.dart';

enum KycGateReason { goalCreation, contribution, redemption, highValueOrder }

enum KycBlockState {
  notStarted,
  inReview,
  rejected,
  enhancedRequired,
  statusUnknown,
}

sealed class KycGateDecision {
  const KycGateDecision();
}

final class KycGateAllow extends KycGateDecision {
  const KycGateAllow();
}

final class KycGateBlock extends KycGateDecision {
  const KycGateBlock({
    required this.state,
    required this.reason,
    this.rejectionReasonCode,
  });

  final KycBlockState state;
  final KycGateReason reason;
  final String? rejectionReasonCode;
}

/// Pure KYC gate — no side effects, no cached auth user.
KycGateDecision decideKycGate({
  required String? kycStatus,
  required KycGateReason reason,
  int? orderTotalPaise,
  bool usesGoldBalance = false,
  int? contributionAmountPaise,
}) {
  if (kycStatus == null) {
    return KycGateBlock(state: KycBlockState.statusUnknown, reason: reason);
  }

  if (reason == KycGateReason.highValueOrder) {
    final total = orderTotalPaise ?? 0;
    if (total <= KycThresholds.orderKycRequiredPaise) {
      return const KycGateAllow();
    }
  }

  if (isKycVerified(kycStatus)) {
    if (reason == KycGateReason.contribution &&
        contributionAmountPaise != null &&
        contributionAmountPaise > KycThresholds.enhancedContributionPaise &&
        !isEnhancedVerified(kycStatus)) {
      return KycGateBlock(
        state: KycBlockState.enhancedRequired,
        reason: reason,
      );
    }
    return const KycGateAllow();
  }

  final blockState = switch (kycStatus) {
    'in_review' || 'in_progress' => KycBlockState.inReview,
    'rejected' => KycBlockState.rejected,
    _ => KycBlockState.notStarted,
  };

  return KycGateBlock(state: blockState, reason: reason);
}

KycGateReason? checkoutKycReason({
  required int orderTotalPaise,
  required bool usesGoldBalance,
}) {
  if (usesGoldBalance) {
    return KycGateReason.redemption;
  }
  if (orderTotalPaise > KycThresholds.orderKycRequiredPaise) {
    return KycGateReason.highValueOrder;
  }
  return null;
}
