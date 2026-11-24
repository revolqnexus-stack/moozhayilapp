import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Resolves the API base URL for the current runtime.
///
/// Production/staging builds MUST pass:
/// `--dart-define=API_BASE_URL=https://api.example.com/v1`
///
/// Android emulators use `10.0.2.2` in debug when no override is set.
String resolveApiBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) {
    return override.endsWith('/v1') ? override : '$override/v1';
  }

  if (kReleaseMode) {
    return 'https://moozhayilapp-prod.onrender.com/v1';
  }

  if (kIsWeb) {
    return 'https://moozhayilapp-prod.onrender.com/v1';
  }

  if (!kIsWeb && Platform.isAndroid) {
    return 'https://moozhayilapp-prod.onrender.com/v1';
  }

  return 'https://moozhayilapp-prod.onrender.com/v1';
}

/// Whether push registration should use Firebase in this build.
bool get pushRegistrationEnabled {
  return const bool.fromEnvironment('PUSH_ENABLED', defaultValue: false);
}

/// Debug-only mock push tokens (never used in release).
bool get pushMockTokensEnabled {
  return kDebugMode &&
      const bool.fromEnvironment('PUSH_MOCK', defaultValue: false);
}
