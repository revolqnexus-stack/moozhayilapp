import '../services/api_service.dart';

/// Maps thrown errors to calm, customer-safe copy — never raw exceptions.
abstract final class CustomerErrorCopy {
  static String message(Object? error) {
    if (error == null) {
      return _generic;
    }
    if (error is ApiException) {
      if (error.code == 'PROVIDER_UNAVAILABLE') {
        return 'We couldn\u2019t send a verification code. Please try again in a moment.';
      }
      if (error.code == 'RATE_LIMITED') {
        return 'Too many attempts. Please wait about 10 minutes, then try again.';
      }
      return error.message;
    }

    final text = error.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('connection') ||
        text.contains('network') ||
        text.contains('failed host lookup')) {
      return 'Please check your internet connection and try again.';
    }
    if (text.contains('timeout') || text.contains('timed out')) {
      return 'This is taking longer than expected. Please try again.';
    }
    if (text.contains('401') || text.contains('unauthorized')) {
      return 'Please sign in again to continue.';
    }

    return _generic;
  }

  static const _generic = 'Something went wrong. Please try again in a moment.';
}
