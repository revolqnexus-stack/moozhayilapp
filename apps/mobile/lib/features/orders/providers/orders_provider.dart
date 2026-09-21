import 'dart:math';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/order.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';

part 'orders_provider.g.dart';

String _idempotencyKey() =>
    '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

class OrdersRepository {
  const OrdersRepository(this._apiService);

  final ApiService _apiService;

  Future<OrdersListResponse> list({String status = 'all'}) async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/orders',
        queryParameters: {'status': status},
      );
      return OrdersListResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<OrderDetailResponse> detail(String orderId) async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/orders/$orderId',
      );
      return OrderDetailResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CreateOrderResponse> create({
    required String quoteId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddressId,
    required String paymentMethod,
    String? paymentMethodId,
    String? useGoldBalanceGrams,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/orders',
        data: {
          'quote_id': quoteId,
          'items': items,
          'delivery_address_id': deliveryAddressId,
          'payment_method': paymentMethod,
          'payment_method_id': ?paymentMethodId,
          'use_gold_balance_grams': ?useGoldBalanceGrams,
        },
        options: Options(headers: {'Idempotency-Key': _idempotencyKey()}),
      );
      return CreateOrderResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CancelOrderResponse> cancel(String orderId, String reason) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/orders/$orderId/cancel',
        data: {'reason': reason},
      );
      return CancelOrderResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
OrdersRepository ordersRepository(Ref ref) {
  return OrdersRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<OrdersListResponse> ordersList(Ref ref, {String status = 'all'}) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return const OrdersListResponse(data: [], hasMore: false);
  }

  return ref.watch(ordersRepositoryProvider).list(status: status);
}

@riverpod
Future<OrderDetailResponse> orderDetail(Ref ref, String orderId) async {
  return ref.watch(ordersRepositoryProvider).detail(orderId);
}

@riverpod
class OrderActions extends _$OrderActions {
  @override
  FutureOr<void> build() {}

  Future<CreateOrderResponse> placeOrder({
    required String quoteId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddressId,
    required String paymentMethod,
    String? paymentMethodId,
    String? useGoldBalanceGrams,
  }) async {
    final response = await ref
        .read(ordersRepositoryProvider)
        .create(
          quoteId: quoteId,
          items: items,
          deliveryAddressId: deliveryAddressId,
          paymentMethod: paymentMethod,
          paymentMethodId: paymentMethodId,
          useGoldBalanceGrams: useGoldBalanceGrams,
        );
    ref.invalidate(ordersListProvider());
    ref.invalidate(cartSummaryProvider);
    return response;
  }

  Future<CancelOrderResponse> cancelOrder(String orderId, String reason) async {
    final response = await ref
        .read(ordersRepositoryProvider)
        .cancel(orderId, reason);
    ref.invalidate(ordersListProvider());
    ref.invalidate(orderDetailProvider(orderId));
    return response;
  }
}
