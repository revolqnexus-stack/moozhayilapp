/// Locked architecture KYC monetary thresholds in paise.
abstract final class KycThresholds {
  static const int orderKycRequiredPaise = 5000000;
  static const int panRequiredPaise = 20000000;
  static const int enhancedContributionPaise = 5000000;
  static const int resubmissionCooldownHours = 24;
  static const int estimatedReviewMinutes = 30;
}

bool isKycVerified(String status) {
  return status == 'basic_verified' || status == 'enhanced_verified';
}

bool isEnhancedVerified(String status) => status == 'enhanced_verified';
