import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/dev_preview.dart';
import '../../../core/constants/kyc_thresholds.dart';
import '../../../core/kyc/decide_kyc_gate.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'profile_provider.g.dart';

class ProfileRepository {
  const ProfileRepository(this._apiService);

  final ApiService _apiService;

  Future<User> me() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/user/me',
      );
      return User.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? city,
  }) async {
    try {
      final response = await _apiService.client.patch<Map<String, dynamic>>(
        '/user/me',
        data: {?name, ?email, ?city},
      );
      return User.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<User> profileUser(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    throw const ApiException('Sign in to view profile');
  }

  if (DevPreview.enabled && auth.value?.user?.id == DevPreview.previewUser.id) {
    return auth.value!.user!;
  }

  return ref.watch(profileRepositoryProvider).me();
}

@riverpod
class ProfileActions extends _$ProfileActions {
  @override
  FutureOr<void> build() {}

  Future<User> updateProfile({
    String? name,
    String? email,
    String? city,
  }) async {
    final user = await ref
        .read(profileRepositoryProvider)
        .updateProfile(name: name, email: email, city: city);
    ref.invalidate(profileUserProvider);
    await ref.read(authControllerProvider.notifier).refreshMe();
    return user;
  }
}

bool kycGateRequiredForCheckout(int totalPaise, String kycStatus) {
  return checkoutKycReason(
        orderTotalPaise: totalPaise,
        usesGoldBalance: false,
      ) !=
      null &&
      !isKycVerified(kycStatus);
}

bool panGateRequiredForCheckout(int totalPaise, bool panVerified) =>
    totalPaise > KycThresholds.panRequiredPaise && !panVerified;
