import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_provider.dart';

class CartCountOverride extends Notifier<int?> {
  @override
  int? build() => null;

  void setCount(int count) => state = count;
}

final cartCountOverrideProvider =
    NotifierProvider<CartCountOverride, int?>(CartCountOverride.new);

final cartBadgeCountProvider = Provider<int>((ref) {
  final override = ref.watch(cartCountOverrideProvider);
  if (override != null) return override;

  return ref.watch(cartSummaryProvider).maybeWhen(
        data: (summary) => summary.itemCount,
        orElse: () => 0,
      );
});
