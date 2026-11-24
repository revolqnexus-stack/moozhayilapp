import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'plans_provider.g.dart';

class PlansRepository {
  const PlansRepository(this._apiService);

  final ApiService _apiService;

  Future<void> registerInterest(String schemeType) async {
    try {
      await _apiService.client.post<Map<String, dynamic>>(
        '/plans/interest',
        data: {'scheme_type': schemeType},
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<String>> myInterestSchemes() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/plans/interest',
      );
      final interests = response.data!['interests'] as List<dynamic>? ?? [];
      return interests
          .map(
            (item) => (item as Map<String, dynamic>)['scheme_type'] as String,
          )
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
PlansRepository plansRepository(Ref ref) {
  return PlansRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<List<String>> myPlanInterests(Ref ref) async {
  if (watchSignedInUserId(ref) == null) {
    return const [];
  }

  return ref.watch(plansRepositoryProvider).myInterestSchemes();
}

@riverpod
class PlanInterestActions extends _$PlanInterestActions {
  @override
  FutureOr<void> build() {}

  Future<void> register(String schemeType) async {
    await ref.read(plansRepositoryProvider).registerInterest(schemeType);
    ref.invalidate(myPlanInterestsProvider);
  }
}
