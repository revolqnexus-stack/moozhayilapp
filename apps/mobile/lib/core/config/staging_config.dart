/// True only when the build explicitly opts into staging QA behaviour.
/// Pass `--dart-define=STAGING_BUILD=true` for staging APKs.
bool get isStagingApiBuild {
  return const bool.fromEnvironment('STAGING_BUILD', defaultValue: false);
}

/// Fixed OTP used when the backend runs with SMS_PROVIDER_MODE=mock.
const stagingMockOtp = '123456';

String get stagingOtpHint {
  if (!isStagingApiBuild) {
    return '';
  }
  return 'Testing build: SMS is not sent. Use OTP $stagingMockOtp.';
}
