import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/ghost_button.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/customer_copy.dart';
import '../../../core/constants/kyc_thresholds.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/kyc/decide_kyc_gate.dart';
import '../../../core/kyc/kyc_rejection_copy.dart';
import '../../../core/models/kyc_status.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/kyc_provider.dart';

export '../../../core/kyc/decide_kyc_gate.dart' show KycGateReason;

extension KycGateReasonCopy on KycGateReason {
  String get headline {
    switch (this) {
      case KycGateReason.goalCreation:
        return 'Verify to join a Scheme';
      case KycGateReason.contribution:
        return 'Verify to contribute to your Scheme';
      case KycGateReason.redemption:
        return 'Verify to use My Gold';
      case KycGateReason.highValueOrder:
        return 'Verify to complete this order';
    }
  }

  String bodyFor(KycBlockState state) {
    if (state == KycBlockState.enhancedRequired) {
      return CustomerCopy.kycGateEnhancedBody;
    }
    switch (this) {
      case KycGateReason.goalCreation:
        return CustomerCopy.kycGateGoalBody;
      case KycGateReason.contribution:
        return CustomerCopy.kycGateContributionBody;
      case KycGateReason.redemption:
        return CustomerCopy.kycGateRedemptionBody;
      case KycGateReason.highValueOrder:
        return CustomerCopy.kycGateHighValueOrderBody;
    }
  }
}

Future<void> showKycGateBottomSheet({
  required BuildContext context,
  required KycGateReason reason,
  required String returnRoute,
  KycGateBlock? block,
  KycStatusResponse? kyc,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => KycGateBottomSheet(
      reason: reason,
      returnRoute: returnRoute,
      block: block,
      kyc: kyc,
    ),
  );
}

/// Fetches fresh KYC status (shimmer), then shows allow/block UI.
Future<bool> showKycGateFlow({
  required BuildContext context,
  required WidgetRef ref,
  required KycGateReason reason,
  required String returnRoute,
  int? orderTotalPaise,
  bool usesGoldBalance = false,
  int? contributionAmountPaise,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (context) => _KycGateFlowSheet(
      reason: reason,
      returnRoute: returnRoute,
      orderTotalPaise: orderTotalPaise,
      usesGoldBalance: usesGoldBalance,
      contributionAmountPaise: contributionAmountPaise,
    ),
  );
  return result ?? false;
}

class _KycGateFlowSheet extends ConsumerStatefulWidget {
  const _KycGateFlowSheet({
    required this.reason,
    required this.returnRoute,
    this.orderTotalPaise,
    this.usesGoldBalance = false,
    this.contributionAmountPaise,
  });

  final KycGateReason reason;
  final String returnRoute;
  final int? orderTotalPaise;
  final bool usesGoldBalance;
  final int? contributionAmountPaise;

  @override
  ConsumerState<_KycGateFlowSheet> createState() => _KycGateFlowSheetState();
}

class _KycGateFlowSheetState extends ConsumerState<_KycGateFlowSheet> {
  KycGateDecision? _decision;
  KycStatusResponse? _kyc;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _decision = null;
      _kyc = null;
      _error = null;
    });
    try {
      ref.invalidate(kycStatusProvider);
      final kyc = await ref.read(kycStatusProvider.future);
      final decision = decideKycGate(
        kycStatus: kyc.kycStatus,
        reason: widget.reason,
        orderTotalPaise: widget.orderTotalPaise,
        usesGoldBalance: widget.usesGoldBalance,
        contributionAmountPaise: widget.contributionAmountPaise,
      );
      if (!mounted) return;
      if (decision is KycGateAllow) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {
        _decision = decision;
        _kyc = kyc;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _decision = KycGateBlock(
          state: KycBlockState.statusUnknown,
          reason: widget.reason,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_decision == null && _error == null) {
      return const _KycGateSheetChrome(
        child: LoadingShimmer(width: double.infinity, height: 120),
      );
    }

    final block = _decision! as KycGateBlock;
    return KycGateBottomSheet(
      reason: widget.reason,
      returnRoute: widget.returnRoute,
      block: block,
      kyc: _kyc,
      onRetry: block.state == KycBlockState.statusUnknown ? _load : null,
    );
  }
}

class KycGateBottomSheet extends StatelessWidget {
  const KycGateBottomSheet({
    super.key,
    required this.reason,
    required this.returnRoute,
    this.block,
    this.kyc,
    this.onRetry,
  });

  final KycGateReason reason;
  final String returnRoute;
  final KycGateBlock? block;
  final KycStatusResponse? kyc;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final state = block?.state ?? KycBlockState.notStarted;
    final showStartCta = state == KycBlockState.notStarted;
    final showResubmitCta = state == KycBlockState.rejected;
    final showRetryCta = state == KycBlockState.statusUnknown;

    return _KycGateSheetChrome(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(reason.headline, style: AppTypography.headingSM),
          const SizedBox(height: AppSpacing.sm),
          Text(
            state == KycBlockState.inReview
                ? CustomerCopy.kycPendingReviewSla(
                    KycThresholds.estimatedReviewMinutes,
                  )
                : reason.bodyFor(state),
            style: AppTypography.uiBodySM.copyWith(color: AppColors.slateMist),
          ),
          if (state == KycBlockState.rejected) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              kycRejectionMessage(kyc?.rejectionReason),
              style: AppTypography.uiBodySM.copyWith(
                color: AppColors.blushClay,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (showStartCta || showResubmitCta)
            Semantics(
              button: true,
              label: 'Continue verification',
              child: SizedBox(
                height: 48,
                child: PrimaryButton(
                  label: 'Continue verification',
                  isFullWidth: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(
                      Uri(
                        path: AppRoutes.profileKyc,
                        queryParameters: {'from': returnRoute},
                      ).toString(),
                    );
                  },
                ),
              ),
            ),
          if (showRetryCta) ...[
            Semantics(
              button: true,
              label: 'Retry verification check',
              child: SizedBox(
                height: 48,
                child: PrimaryButton(
                  label: 'Retry',
                  isFullWidth: true,
                  onTap: onRetry,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Semantics(
            button: true,
            label: 'Close',
            child: SizedBox(
              height: 48,
              child: GhostButton(
                label: state == KycBlockState.inReview
                    ? 'Close'
                    : 'Skip for now',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KycGateSheetChrome extends StatelessWidget {
  const _KycGateSheetChrome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.bottomSheet),
          topRight: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSpacing.bottomSheetHandleWidth,
              height: AppSpacing.bottomSheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.smokeLine,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
