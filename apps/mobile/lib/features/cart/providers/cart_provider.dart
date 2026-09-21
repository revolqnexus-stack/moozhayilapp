import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/cart.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/indian_format.dart';
import '../../auth/providers/auth_provider.dart';

part 'cart_provider.g.dart';

class CartRepository {
  const CartRepository(this._apiService);

  final ApiService _apiService;

  Future<CartSummary> getCart() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/cart',
      );
      return CartSummary.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CartSummary> addItem(String productId, {int quantity = 1}) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/cart/items',
        data: {'product_id': productId, 'quantity': quantity},
      );
      return CartSummary.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CartSummary> removeItem(String productId) async {
    try {
      final response = await _apiService.client.delete<Map<String, dynamic>>(
        '/cart/items/$productId',
      );
      return CartSummary.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> clear() async {
    try {
      await _apiService.client.delete<void>('/cart');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
CartRepository cartRepository(Ref ref) {
  return CartRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<CartSummary> cartSummary(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return CartSummary(
      items: const [],
      subtotalPaise: 0,
      subtotalDisplay: IndianFormat.formatInrPaise(0),
      itemCount: 0,
    );
  }

  return ref.watch(cartRepositoryProvider).getCart();
}

@riverpod
class CartActions extends _$CartActions {
  @override
  FutureOr<void> build() {}

  Future<CartSummary> addProduct(String productId) async {
    final summary = await ref.read(cartRepositoryProvider).addItem(productId);
    ref.invalidate(cartSummaryProvider);
    return summary;
  }

  Future<CartSummary> removeProduct(String productId) async {
    final summary = await ref
        .read(cartRepositoryProvider)
        .removeItem(productId);
    ref.invalidate(cartSummaryProvider);
    return summary;
  }

  Future<void> clearCart() async {
    await ref.read(cartRepositoryProvider).clear();
    ref.invalidate(cartSummaryProvider);
  }
}
