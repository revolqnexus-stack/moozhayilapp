import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_summary_display.dart';

class CartCountOverride extends Notifier<int?> {
  @override
  int? build() => null;

  void setCount(int count) => state = count;
}

final cartCountOverrideProvider = NotifierProvider<CartCountOverride, int?>(
  CartCountOverride.new,
);

final cartBadgeCountProvider = Provider<int>((ref) {
  final override = ref.watch(cartCountOverrideProvider);
  if (override != null) return override;

  return ref
      .watch(cartDisplaySummaryProvider)
      .maybeWhen(data: (summary) => summary.itemCount, orElse: () => 0);
});
