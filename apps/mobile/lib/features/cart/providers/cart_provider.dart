import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/cart.dart';
import '../../../core/models/price_quote.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/indian_format.dart';
import '../../auth/providers/auth_provider.dart';
import 'cart_badge_provider.dart';
import 'cart_summary_display.dart';

part 'cart_provider.g.dart';

class CartRepository {
  const CartRepository(this._apiService);

  final ApiService _apiService;

  CartSummary _parseSummary(Map<String, dynamic> raw) {
    _normalizeCartPayload(raw);
    try {
      return CartSummary.fromJson(raw);
    } on Object catch (_) {
      throw const ApiException(
        'We couldn\u2019t load your bag. Please try again.',
      );
    }
  }

  void _normalizeCartPayload(Map<String, dynamic> raw) {
    final items = raw['items'];
    if (items is! List) {
      return;
    }
    for (final entry in items) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      final product = entry['product'];
      if (product is! Map<String, dynamic>) {
        continue;
      }
      final weight = product['weight_grams'];
      if (weight is num) {
        product['weight_grams'] = weight.toString();
      }
    }
  }

  Future<CartSummary> getCart() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/cart',
      );
      return _parseSummary(response.data!);
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
      return _parseSummary(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<CartSummary> removeItem(String productId) async {
    try {
      final response = await _apiService.client.delete<Map<String, dynamic>>(
        '/cart/items/$productId',
      );
      return _parseSummary(response.data!);
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

  Future<PriceQuote> createQuoteFromCart() async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/quotes/from-cart',
      );
      return PriceQuote.fromJson(response.data!);
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

  return ref.read(cartRepositoryProvider).getCart();
}

@riverpod
class CartActions extends _$CartActions {
  @override
  FutureOr<void> build() {}

  Future<CartSummary> addProduct(String productId) async {
    final summary = await ref.read(cartRepositoryProvider).addItem(productId);
    ref.read(cartCountOverrideProvider.notifier).setCount(summary.itemCount);
    ref.read(cartSummaryOverrideProvider.notifier).setSummary(summary);
    ref.invalidate(cartSummaryProvider);
    return summary;
  }

  Future<CartSummary> removeProduct(String productId) async {
    final summary = await ref
        .read(cartRepositoryProvider)
        .removeItem(productId);
    ref.read(cartCountOverrideProvider.notifier).setCount(summary.itemCount);
    ref.read(cartSummaryOverrideProvider.notifier).setSummary(summary);
    ref.invalidate(cartSummaryProvider);
    return summary;
  }

  Future<void> clearCart() async {
    await ref.read(cartRepositoryProvider).clear();
    ref.invalidate(cartSummaryProvider);
  }
}
