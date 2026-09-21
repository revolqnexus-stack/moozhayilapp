import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/gold_balance.dart';
import '../../../core/models/product.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/indian_format.dart';
import '../../auth/providers/auth_provider.dart';

part 'gold_balance_provider.g.dart';

class GoldBalanceRepository {
  const GoldBalanceRepository(this._apiService);

  final ApiService _apiService;

  Future<GoldBalance> getBalance() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/gold-balance',
      );
      return GoldBalance.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<GoldLedgerResponse> getLedger({String? goalId}) async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/gold-balance/ledger',
        queryParameters: {'goal_id': ?goalId, 'limit': 20},
      );
      return GoldLedgerResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<Product>> getRedeemableProducts() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/gold-balance/redeemable-products',
        queryParameters: {'limit': 20},
      );
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<PendingContributionsResponse> getPendingContributions() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/contributions/pending',
      );
      return PendingContributionsResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
GoldBalanceRepository goldBalanceRepository(Ref ref) {
  return GoldBalanceRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<GoldBalance> goldBalance(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return GoldBalance(
      totalGrams: '0.0000',
      totalGramsDisplay: IndianFormat.formatGrams('0'),
      totalValuePaise: 0,
      totalValueDisplay: IndianFormat.formatInrPaise(0),
      rateUsed: GoldRateUsed(
        purity: '22k',
        ratePaise: 0,
        rateDisplay: '${IndianFormat.formatInrPaise(0)}/g',
        updatedAt: '',
      ),
    );
  }

  return ref.watch(goldBalanceRepositoryProvider).getBalance();
}

@riverpod
Future<GoldLedgerResponse> goldLedger(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return const GoldLedgerResponse(data: [], hasMore: false);
  }

  return ref.watch(goldBalanceRepositoryProvider).getLedger();
}

@riverpod
Future<List<Product>> redeemableProducts(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return const [];
  }

  return ref.watch(goldBalanceRepositoryProvider).getRedeemableProducts();
}

@riverpod
Future<PendingContributionsResponse> pendingContributions(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return const PendingContributionsResponse(pending: []);
  }

  return ref.watch(goldBalanceRepositoryProvider).getPendingContributions();
}
