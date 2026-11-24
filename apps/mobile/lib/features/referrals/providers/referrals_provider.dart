import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/referral.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'referrals_provider.g.dart';

class ReferralsRepository {
  const ReferralsRepository(this._apiService);

  final ApiService _apiService;

  Future<ReferralCodeResponse> myCode() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/referrals/my-code',
      );
      return ReferralCodeResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ApplyReferralResponse> apply(String referralCode) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/referrals/apply',
        data: {'referral_code': referralCode},
      );
      return ApplyReferralResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ReferralHistoryResponse> history() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/referrals/history',
      );
      return ReferralHistoryResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
ReferralsRepository referralsRepository(Ref ref) {
  return ReferralsRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<ReferralCodeResponse> referralCode(Ref ref) async {
  if (watchSignedInUserId(ref) == null) {
    throw const ApiException('Sign in to view your referral code');
  }

  return ref.watch(referralsRepositoryProvider).myCode();
}

@riverpod
Future<ReferralHistoryResponse> referralHistory(Ref ref) async {
  if (watchSignedInUserId(ref) == null) {
    return const ReferralHistoryResponse(referrals: []);
  }

  return ref.watch(referralsRepositoryProvider).history();
}

@riverpod
class ReferralActions extends _$ReferralActions {
  @override
  FutureOr<void> build() {}

  Future<ApplyReferralResponse> apply(String referralCode) async {
    final response = await ref
        .read(referralsRepositoryProvider)
        .apply(referralCode);
    ref.invalidate(referralHistoryProvider);
    return response;
  }
}
