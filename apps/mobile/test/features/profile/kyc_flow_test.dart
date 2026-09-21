import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/constants/kyc_thresholds.dart';
import 'package:moozhayil/core/kyc/decide_kyc_gate.dart';
import 'package:moozhayil/core/models/kyc_status.dart';
import 'package:moozhayil/features/profile/providers/profile_provider.dart';

void main() {
  group('KYC thresholds', () {
    test('checkout requires KYC above order threshold when unverified', () {
      expect(
        kycGateRequiredForCheckout(
          KycThresholds.orderKycRequiredPaise + 1,
          'not_started',
        ),
        isTrue,
      );
      expect(
        kycGateRequiredForCheckout(1_000_000, 'basic_verified'),
        isFalse,
      );
    });
  });

  group('KycStatusResponse parsing', () {
    test('parses status payload safely', () {
      final model = KycStatusResponse.fromJson({
        'kyc_status': 'in_review',
        'aadhaar_verified': true,
        'pan_verified': false,
        'selfie_verified': true,
        'submitted_at': '2026-06-26T04:30:00Z',
        'rejection_reason': null,
        'resubmission_allowed_at': null,
      });

      expect(model.kycStatus, 'in_review');
      expect(model.aadhaarVerified, isTrue);
      expect(model.selfieVerified, isTrue);
    });
  });

  group('decideKycGate redemption', () {
    test('verified user may redeem', () {
      expect(
        decideKycGate(
          kycStatus: 'basic_verified',
          reason: KycGateReason.redemption,
        ),
        isA<KycGateAllow>(),
      );
    });
  });
}
