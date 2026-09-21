import '../constants/customer_copy.dart';

/// Maps server rejection reason codes to customer-safe copy.
/// Never render raw admin notes in gate UI.
String kycRejectionMessage(String? reasonCodeOrText) {
  if (reasonCodeOrText == null || reasonCodeOrText.trim().isEmpty) {
    return CustomerCopy.kycRejectionGeneric;
  }

  final normalized = reasonCodeOrText.trim().toUpperCase();

  return switch (normalized) {
    'NAME_MISMATCH' => CustomerCopy.kycRejectionNameMismatch,
    'DOCUMENT_UNREADABLE' => CustomerCopy.kycRejectionDocumentUnreadable,
    'SELFIE_MISMATCH' => CustomerCopy.kycRejectionSelfieMismatch,
    'EXPIRED_DOCUMENT' => CustomerCopy.kycRejectionExpiredDocument,
    _ => CustomerCopy.kycRejectionGeneric,
  };
}
