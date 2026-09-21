import 'dart:math';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/goal.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/indian_format.dart';
import '../../auth/providers/auth_provider.dart';

part 'goals_provider.g.dart';

String _idempotencyKey() =>
    '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

class GoalsRepository {
  const GoalsRepository(this._apiService);

  final ApiService _apiService;

  Future<GoalsListResponse> list({String status = 'all'}) async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/goals',
        queryParameters: {'status': status},
      );
      return GoalsListResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<GoalDetailResponse> detail(String goalId) async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/goals/$goalId',
      );
      return GoalDetailResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CreateGoalResponse> create({
    required String schemeType,
    required String goalType,
    required String name,
    required int monthlyAmountPaise,
    required int durationMonths,
    required String startDate,
    String? targetProductId,
    int? targetAmountPaise,
    String? paymentMethodId,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/goals',
        data: {
          'scheme_type': schemeType,
          'goal_type': goalType,
          'name': name,
          'monthly_amount_paise': monthlyAmountPaise,
          'duration_months': durationMonths,
          'start_date': startDate,
          'target_product_id': ?targetProductId,
          'target_amount_paise': ?targetAmountPaise,
          'payment_method_id': ?paymentMethodId,
        },
        options: Options(headers: {'Idempotency-Key': _idempotencyKey()}),
      );
      return CreateGoalResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<ContributeResponse> contribute({
    required String goalId,
    required int amountPaise,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/goals/$goalId/contribute',
        data: {'amount_paise': amountPaise},
        options: Options(headers: {'Idempotency-Key': _idempotencyKey()}),
      );
      return ContributeResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Goal> pause(String goalId) async {
    try {
      final response = await _apiService.client.patch<Map<String, dynamic>>(
        '/goals/$goalId',
        data: {'status': 'paused'},
      );
      return Goal.fromJson(response.data!['goal'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CancelGoalResponse> cancel(String goalId) async {
    try {
      final response = await _apiService.client.delete<Map<String, dynamic>>(
        '/goals/$goalId',
      );
      return CancelGoalResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
GoalsRepository goalsRepository(Ref ref) {
  return GoalsRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<GoalsListResponse> goalsList(Ref ref, {String status = 'all'}) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return GoalsListResponse(
      goals: const [],
      summary: GoalsSummary(
        totalGrams: '0.0000',
        totalGramsDisplay: IndianFormat.formatGrams('0'),
        totalValuePaise: 0,
        totalValueDisplay: IndianFormat.formatInrPaise(0),
        activeCount: 0,
        monthlyTotalPaise: 0,
        monthlyTotalDisplay: '${IndianFormat.formatInrPaise(0)}/mo',
      ),
    );
  }

  return ref.watch(goalsRepositoryProvider).list(status: status);
}

@riverpod
Future<GoalDetailResponse> goalDetail(Ref ref, String goalId) async {
  return ref.watch(goalsRepositoryProvider).detail(goalId);
}
