import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cart.dart';
import 'cart_provider.dart';

/// Last good bag snapshot from add/remove — keeps Bag usable if refetch fails.
class CartSummaryOverride extends Notifier<CartSummary?> {
  @override
  CartSummary? build() => null;

  void setSummary(CartSummary summary) => state = summary;

  void clear() => state = null;
}

final cartSummaryOverrideProvider =
    NotifierProvider<CartSummaryOverride, CartSummary?>(
      CartSummaryOverride.new,
    );

/// Bag state for UI: mutation snapshot → live fetch → empty signed-out cart.
final cartDisplaySummaryProvider = Provider<AsyncValue<CartSummary>>((ref) {
  ref.listen(cartSummaryProvider, (_, next) {
    next.whenData((_) {
      ref.read(cartSummaryOverrideProvider.notifier).clear();
    });
  });

  final override = ref.watch(cartSummaryOverrideProvider);
  final fetched = ref.watch(cartSummaryProvider);

  if (override != null) {
    return fetched.when(
      data: (summary) => AsyncData(summary),
      loading: () => AsyncData(override),
      error: (_, _) => AsyncData(override),
    );
  }

  return fetched;
});
