/// True for staging APK builds pointed at Render / non-production hosts.
bool get isStagingApiBuild {
  const apiBase = String.fromEnvironment('API_BASE_URL');
  if (apiBase.isEmpty) {
    return false;
  }

  return apiBase.contains('onrender.com') ||
      apiBase.contains('staging') ||
      apiBase.contains('localhost');
}

/// Fixed OTP used when the backend runs with SMS_PROVIDER_MODE=mock.
const stagingMockOtp = '123456';

String get stagingOtpHint {
  if (!isStagingApiBuild) {
    return '';
  }
  return 'Testing build: SMS is not sent. Use OTP $stagingMockOtp.';
}
