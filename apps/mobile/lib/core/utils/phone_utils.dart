/// Normalizes Indian phone numbers to E.164 (+91XXXXXXXXXX).
String normalizeIndianPhone(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return trimmed;

  if (trimmed.startsWith('+')) {
    return '+$digits';
  }
  if (digits.length == 10) {
    return '+91$digits';
  }
  if (digits.length == 12 && digits.startsWith('91')) {
    return '+$digits';
  }
  if (digits.startsWith('91') && digits.length > 10) {
    return '+$digits';
  }

  return trimmed.startsWith('+') ? trimmed : '+$digits';
}

bool isValidIndianPhone(String phone) {
  final normalized = normalizeIndianPhone(phone);
  return RegExp(r'^\+91[6-9]\d{9}$').hasMatch(normalized);
}

/// Last 10 digits for UI (handles pasted +91… numbers).
String indianMobileDigitsOnly(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 10) {
    return digits;
  }
  return digits.substring(digits.length - 10);
}

String formatIndianPhoneLabel(String raw) {
  final digits = indianMobileDigitsOnly(raw);
  return digits.isEmpty ? 'XXXXXXXXXX' : digits;
}
