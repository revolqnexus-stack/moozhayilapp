import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/vault_item.dart';
import 'vault_provider.dart';

class VaultListCache extends Notifier<VaultListResponse?> {
  @override
  VaultListResponse? build() => null;

  void remember(VaultListResponse response) => state = response;
}

final vaultListCacheProvider =
    NotifierProvider<VaultListCache, VaultListResponse?>(VaultListCache.new);

/// Dream Vault list with last-good fallback when refetch fails.
void forgetVaultProductInCache(WidgetRef ref, String productId) {
  final cache = ref.read(vaultListCacheProvider);
  if (cache == null) {
    return;
  }
  final items = cache.items
      .where((item) => item.product.id != productId)
      .toList(growable: false);
  if (items.length == cache.items.length) {
    return;
  }
  ref
      .read(vaultListCacheProvider.notifier)
      .remember(VaultListResponse(items: items, count: items.length));
}

void rememberVaultItemInCache(WidgetRef ref, VaultItem item) {
  final cache = ref.read(vaultListCacheProvider);
  if (cache == null) {
    ref
        .read(vaultListCacheProvider.notifier)
        .remember(VaultListResponse(items: [item], count: 1));
    return;
  }
  if (cache.items.any((existing) => existing.product.id == item.product.id)) {
    return;
  }
  final items = [item, ...cache.items];
  ref
      .read(vaultListCacheProvider.notifier)
      .remember(VaultListResponse(items: items, count: items.length));
}

final vaultDisplayItemsProvider = Provider<AsyncValue<VaultListResponse>>((
  ref,
) {
  ref.listen(vaultItemsProvider, (_, next) {
    next.whenData((response) {
      ref.read(vaultListCacheProvider.notifier).remember(response);
    });
  });

  final fetched = ref.watch(vaultItemsProvider);
  final cache = ref.watch(vaultListCacheProvider);

  return fetched.when(
    data: (response) => AsyncData(response),
    loading: () =>
        cache != null ? AsyncData(cache) : const AsyncValue.loading(),
    error: (error, stack) =>
        cache != null ? AsyncData(cache) : AsyncValue.error(error, stack),
  );
});
