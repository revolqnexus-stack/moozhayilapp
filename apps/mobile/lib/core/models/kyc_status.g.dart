// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycStatusResponse _$KycStatusResponseFromJson(Map<String, dynamic> json) =>
    _KycStatusResponse(
      kycStatus: json['kyc_status'] as String,
      aadhaarVerified: json['aadhaar_verified'] as bool? ?? false,
      panVerified: json['pan_verified'] as bool? ?? false,
      bankVerified: json['bank_verified'] as bool? ?? false,
      selfieVerified: json['selfie_verified'] as bool? ?? false,
      submittedAt: json['submitted_at'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      resubmissionAllowedAt: json['resubmission_allowed_at'] as String?,
    );

Map<String, dynamic> _$KycStatusResponseToJson(_KycStatusResponse instance) =>
    <String, dynamic>{
      'kyc_status': instance.kycStatus,
      'aadhaar_verified': instance.aadhaarVerified,
      'pan_verified': instance.panVerified,
      'bank_verified': instance.bankVerified,
      'selfie_verified': instance.selfieVerified,
      'submitted_at': instance.submittedAt,
      'rejection_reason': instance.rejectionReason,
      'resubmission_allowed_at': instance.resubmissionAllowedAt,
    };

_AadhaarOtpSession _$AadhaarOtpSessionFromJson(Map<String, dynamic> json) =>
    _AadhaarOtpSession(
      sessionId: json['session_id'] as String,
      expiresInSeconds: (json['expires_in_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$AadhaarOtpSessionToJson(_AadhaarOtpSession instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'expires_in_seconds': instance.expiresInSeconds,
    };

_KycSubmitResponse _$KycSubmitResponseFromJson(Map<String, dynamic> json) =>
    _KycSubmitResponse(
      kycStatus: json['kyc_status'] as String,
      estimatedCompletion: json['estimated_completion'] as String,
    );

Map<String, dynamic> _$KycSubmitResponseToJson(_KycSubmitResponse instance) =>
    <String, dynamic>{
      'kyc_status': instance.kycStatus,
      'estimated_completion': instance.estimatedCompletion,
    };
