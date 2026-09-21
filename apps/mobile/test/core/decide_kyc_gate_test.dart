import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/constants/kyc_thresholds.dart';
import 'package:moozhayil/core/kyc/decide_kyc_gate.dart';

void main() {
  group('decideKycGate', () {
    test('allows verified users for contribution below enhanced threshold', () {
      expect(
        decideKycGate(
          kycStatus: 'basic_verified',
          reason: KycGateReason.contribution,
          contributionAmountPaise: KycThresholds.enhancedContributionPaise,
        ),
        isA<KycGateAllow>(),
      );
    });

    test('blocks basic verified above enhanced contribution threshold', () {
      final decision = decideKycGate(
        kycStatus: 'basic_verified',
        reason: KycGateReason.contribution,
        contributionAmountPaise: KycThresholds.enhancedContributionPaise + 1,
      );
      expect(decision, isA<KycGateBlock>());
      expect((decision as KycGateBlock).state, KycBlockState.enhancedRequired);
    });

    test('blocks unverified redemption', () {
      final decision = decideKycGate(
        kycStatus: 'not_started',
        reason: KycGateReason.redemption,
      );
      expect(decision, isA<KycGateBlock>());
      expect((decision as KycGateBlock).state, KycBlockState.notStarted);
    });

    test('allows low-value checkout without KYC', () {
      expect(
        decideKycGate(
          kycStatus: 'not_started',
          reason: KycGateReason.highValueOrder,
          orderTotalPaise: KycThresholds.orderKycRequiredPaise,
        ),
        isA<KycGateAllow>(),
      );
    });

    test('blocks high-value checkout for unverified users', () {
      final decision = decideKycGate(
        kycStatus: 'not_started',
        reason: KycGateReason.highValueOrder,
        orderTotalPaise: KycThresholds.orderKycRequiredPaise + 1,
      );
      expect(decision, isA<KycGateBlock>());
    });

    test('fail closed on unknown status fetch', () {
      final decision = decideKycGate(
        kycStatus: null,
        reason: KycGateReason.contribution,
      );
      expect(decision, isA<KycGateBlock>());
      expect((decision as KycGateBlock).state, KycBlockState.statusUnknown);
    });

    test('maps in_review to inReview block state', () {
      final decision = decideKycGate(
        kycStatus: 'in_review',
        reason: KycGateReason.contribution,
      );
      expect((decision as KycGateBlock).state, KycBlockState.inReview);
    });
  });

  group('checkoutKycReason', () {
    test('returns redemption when using gold balance', () {
      expect(
        checkoutKycReason(orderTotalPaise: 100, usesGoldBalance: true),
        KycGateReason.redemption,
      );
    });

    test('returns null for small cash orders', () {
      expect(
        checkoutKycReason(
          orderTotalPaise: 100,
          usesGoldBalance: false,
        ),
        isNull,
      );
    });
  });
}
