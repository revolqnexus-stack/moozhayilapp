import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/dev_preview.dart';
import '../../../core/models/kyc_status.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'kyc_provider.g.dart';

class PanVerificationResult {
  const PanVerificationResult({
    required this.referenceId,
    required this.valid,
    required this.panStatus,
    required this.message,
    required this.panMasked,
    required this.nameMismatch,
    this.registeredName,
    this.nameMatchResult,
  });

  factory PanVerificationResult.fromJson(Map<String, dynamic> json) {
    return PanVerificationResult(
      referenceId: json['reference_id'] as String? ?? '',
      valid: json['valid'] as bool? ?? false,
      registeredName: json['registered_name'] as String?,
      panStatus: json['pan_status'] as String? ?? '',
      nameMatchResult: json['name_match_result'] as String?,
      message: json['message'] as String? ?? '',
      panMasked: json['pan_masked'] as String? ?? '',
      nameMismatch: json['name_mismatch'] as bool? ?? false,
    );
  }

  final String referenceId;
  final bool valid;
  final String? registeredName;
  final String panStatus;
  final String? nameMatchResult;
  final String message;
  final String panMasked;
  final bool nameMismatch;
}

class KycRepository {
  const KycRepository(this._apiService);

  final ApiService _apiService;

  Future<KycStatusResponse> status() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/kyc/status',
      );
      return KycStatusResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AadhaarOtpSession> sendAadhaarOtp(String aadhaarNumber) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/kyc/aadhaar/send-otp',
        data: {'aadhaar_number': aadhaarNumber},
      );
      return AadhaarOtpSession.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> verifyAadhaarOtp({
    required String sessionId,
    required String otp,
  }) async {
    try {
      await _apiService.client.post<Map<String, dynamic>>(
        '/kyc/aadhaar/verify',
        data: {'session_id': sessionId, 'otp': otp},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<PanVerificationResult> verifyPan({
    required String panNumber,
    String? name,
  }) async {
    final trimmedName = name?.trim();
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/kyc/pan/verify',
        data: {
          'pan_number': panNumber,
          if (trimmedName != null && trimmedName.isNotEmpty) 'name': trimmedName,
        },
      );
      return PanVerificationResult.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> uploadSelfie(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'selfie': await MultipartFile.fromFile(
          filePath,
          filename: 'selfie.jpg',
        ),
      });
      await _apiService.client.post<Map<String, dynamic>>(
        '/kyc/selfie',
        data: formData,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<KycSubmitResponse> submit() async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/kyc/submit',
        data: {},
      );
      return KycSubmitResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
KycRepository kycRepository(Ref ref) {
  return KycRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<KycStatusResponse> kycStatus(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return const KycStatusResponse(kycStatus: 'not_started');
  }

  if (DevPreview.enabled && auth.value?.user?.id == DevPreview.previewUser.id) {
    return KycStatusResponse(kycStatus: auth.value!.user!.kycStatus);
  }

  return ref.watch(kycRepositoryProvider).status();
}

@riverpod
class KycFlowActions extends _$KycFlowActions {
  String? _aadhaarSessionId;

  @override
  FutureOr<void> build() {}

  String? get aadhaarSessionId => _aadhaarSessionId;

  Future<AadhaarOtpSession> sendAadhaarOtp(String aadhaarNumber) async {
    final session = await ref
        .read(kycRepositoryProvider)
        .sendAadhaarOtp(aadhaarNumber);
    _aadhaarSessionId = session.sessionId;
    ref.invalidate(kycStatusProvider);
    return session;
  }

  Future<void> verifyAadhaarOtp(String otp) async {
    final sessionId = _aadhaarSessionId;
    if (sessionId == null) {
      throw const ApiException('Aadhaar session expired. Please resend OTP.');
    }

    await ref
        .read(kycRepositoryProvider)
        .verifyAadhaarOtp(sessionId: sessionId, otp: otp);
    ref.invalidate(kycStatusProvider);
  }

  Future<PanVerificationResult> verifyPan({
    required String panNumber,
    String? name,
  }) async {
    final result = await ref
        .read(kycRepositoryProvider)
        .verifyPan(panNumber: panNumber, name: name);
    ref.invalidate(kycStatusProvider);
    return result;
  }

  Future<void> uploadSelfie(String filePath) async {
    await ref.read(kycRepositoryProvider).uploadSelfie(filePath);
    ref.invalidate(kycStatusProvider);
  }

  Future<KycSubmitResponse> submit() async {
    final result = await ref.read(kycRepositoryProvider).submit();
    ref.invalidate(kycStatusProvider);
    await ref.read(authControllerProvider.notifier).refreshMe();
    return result;
  }
}
