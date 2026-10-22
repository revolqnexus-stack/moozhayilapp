// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_status.freezed.dart';
part 'kyc_status.g.dart';

@freezed
abstract class KycStatusResponse with _$KycStatusResponse {
  const factory KycStatusResponse({
    @JsonKey(name: 'kyc_status') required String kycStatus,
    @JsonKey(name: 'aadhaar_verified') @Default(false) bool aadhaarVerified,
    @JsonKey(name: 'pan_verified') @Default(false) bool panVerified,
    @JsonKey(name: 'bank_verified') @Default(false) bool bankVerified,
    @JsonKey(name: 'selfie_verified') @Default(false) bool selfieVerified,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'resubmission_allowed_at') String? resubmissionAllowedAt,
  }) = _KycStatusResponse;

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$KycStatusResponseFromJson(json);
}

@freezed
abstract class AadhaarOtpSession with _$AadhaarOtpSession {
  const factory AadhaarOtpSession({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'expires_in_seconds') required int expiresInSeconds,
  }) = _AadhaarOtpSession;

  factory AadhaarOtpSession.fromJson(Map<String, dynamic> json) =>
      _$AadhaarOtpSessionFromJson(json);
}

class BankVerifyResponse {
  const BankVerifyResponse({
    required this.verified,
    this.referenceId,
    this.accountStatus,
    this.nameMatchResult,
    this.nameAtBankMasked,
    this.bankName,
    this.branch,
    this.accountMasked,
    this.message,
  });

  final bool verified;
  final String? referenceId;
  final String? accountStatus;
  final String? nameMatchResult;
  final String? nameAtBankMasked;
  final String? bankName;
  final String? branch;
  final String? accountMasked;
  final String? message;

  factory BankVerifyResponse.fromJson(Map<String, dynamic> json) {
    return BankVerifyResponse(
      verified: json['verified'] as bool? ?? false,
      referenceId: json['reference_id'] as String?,
      accountStatus: json['account_status'] as String?,
      nameMatchResult: json['name_match_result'] as String?,
      nameAtBankMasked: json['name_at_bank_masked'] as String?,
      bankName: json['bank_name'] as String?,
      branch: json['branch'] as String?,
      accountMasked: json['account_masked'] as String?,
      message: json['message'] as String?,
    );
  }

  bool get isNameMismatch {
    final result = nameMatchResult?.toUpperCase();
    if (result == null || result.isEmpty) {
      return false;
    }
    return result != 'GOOD_MATCH' &&
        result != 'MATCH' &&
        result != 'PARTIAL_MATCH';
  }
}

class PanVerifyResponse {
  const PanVerifyResponse({
    required this.verified,
    this.referenceId,
    this.panStatus,
    this.nameMatchResult,
    this.nameOnPanMasked,
    this.message,
    this.panType,
  });

  final bool verified;
  final String? referenceId;
  final String? panStatus;
  final String? nameMatchResult;
  final String? nameOnPanMasked;
  final String? message;
  final String? panType;

  factory PanVerifyResponse.fromJson(Map<String, dynamic> json) {
    return PanVerifyResponse(
      verified: json['verified'] as bool? ?? false,
      referenceId: json['reference_id'] as String?,
      panStatus: json['pan_status'] as String?,
      nameMatchResult: json['name_match_result'] as String?,
      nameOnPanMasked: json['name_on_pan_masked'] as String?,
      message: json['message'] as String?,
      panType: json['pan_type'] as String?,
    );
  }

  bool get isNameMismatch {
    final result = nameMatchResult?.toUpperCase();
    return result != null && result.isNotEmpty && result != 'MATCH';
  }
}

@freezed
abstract class KycSubmitResponse with _$KycSubmitResponse {
  const factory KycSubmitResponse({
    @JsonKey(name: 'kyc_status') required String kycStatus,
    @JsonKey(name: 'estimated_completion') required String estimatedCompletion,
  }) = _KycSubmitResponse;

  factory KycSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$KycSubmitResponseFromJson(json);
}
