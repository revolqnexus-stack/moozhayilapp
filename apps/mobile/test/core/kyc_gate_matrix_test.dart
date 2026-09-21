import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/constants/kyc_thresholds.dart';
import 'package:moozhayil/core/kyc/decide_kyc_gate.dart';

void main() {
  group('KYC gate matrix (pure decideKycGate)', () {
    const statuses = [
      'not_started',
      'in_review',
      'rejected',
      'basic_verified',
    ];

    for (final status in statuses) {
      test('contribution / $status', () {
        final d = decideKycGate(
          kycStatus: status,
          reason: KycGateReason.contribution,
          contributionAmountPaise: 300000,
        );
        if (status == 'basic_verified' || status == 'enhanced_verified') {
          expect(d, isA<KycGateAllow>());
        } else {
          expect(d, isA<KycGateBlock>());
        }
      });

      test('redemption / $status', () {
        final d = decideKycGate(
          kycStatus: status,
          reason: KycGateReason.redemption,
        );
        expect(
          d is KycGateAllow,
          status == 'basic_verified',
        );
      });

      test('goalCreation / $status', () {
        final d = decideKycGate(
          kycStatus: status,
          reason: KycGateReason.goalCreation,
        );
        expect(
          d is KycGateAllow,
          status == 'basic_verified',
        );
      });
    }

    test('highValueOrder allows at exactly ₹50,000', () {
      expect(
        decideKycGate(
          kycStatus: 'not_started',
          reason: KycGateReason.highValueOrder,
          orderTotalPaise: KycThresholds.orderKycRequiredPaise,
        ),
        isA<KycGateAllow>(),
      );
    });

    test('highValueOrder blocks above ₹50,000', () {
      expect(
        decideKycGate(
          kycStatus: 'not_started',
          reason: KycGateReason.highValueOrder,
          orderTotalPaise: KycThresholds.orderKycRequiredPaise + 1,
        ),
        isA<KycGateBlock>(),
      );
    });

    test('unknown status fails closed', () {
      expect(
        decideKycGate(
          kycStatus: null,
          reason: KycGateReason.contribution,
        ),
        isA<KycGateBlock>(),
      );
    });
  });
}
