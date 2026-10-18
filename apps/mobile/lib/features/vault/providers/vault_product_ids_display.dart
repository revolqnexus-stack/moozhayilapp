import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'vault_provider.dart';

/// Optimistic Dream Vault / wishlist IDs — updated immediately on heart tap.
class VaultProductIdsOverride extends Notifier<Set<String>?> {
  @override
  Set<String>? build() => null;

  void setIds(Set<String> ids) => state = Set<String>.unmodifiable(ids);

  void clear() => state = null;
}

final vaultProductIdsOverrideProvider =
    NotifierProvider<VaultProductIdsOverride, Set<String>?>(
      VaultProductIdsOverride.new,
    );

/// Last successfully loaded vault product IDs (used while refetching).
class VaultProductIdsCache extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void remember(Set<String> ids) => state = Set<String>.unmodifiable(ids);
}

final vaultProductIdsCacheProvider =
    NotifierProvider<VaultProductIdsCache, Set<String>>(
      VaultProductIdsCache.new,
    );

/// IDs for UI: optimistic override → fresh server data → cached → empty.
final displayVaultProductIdsProvider = Provider<Set<String>>((ref) {
  ref.listen(effectiveVaultProductIdsProvider, (_, next) {
    next.whenData((ids) {
      ref.read(vaultProductIdsCacheProvider.notifier).remember(ids);
      ref.read(vaultProductIdsOverrideProvider.notifier).clear();
    });
  });

  final override = ref.watch(vaultProductIdsOverrideProvider);
  if (override != null) {
    return override;
  }

  final async = ref.watch(effectiveVaultProductIdsProvider);
  return async.when(
    data: (ids) => ids,
    loading: () => ref.watch(vaultProductIdsCacheProvider),
    error: (_, _) => ref.watch(vaultProductIdsCacheProvider),
  );
});

void applyOptimisticVaultToggle(
  WidgetRef ref, {
  required String productId,
  required bool saving,
}) {
  final current = ref.read(displayVaultProductIdsProvider);
  final next = Set<String>.from(current);
  if (saving) {
    next.add(productId);
  } else {
    next.remove(productId);
  }
  ref.read(vaultProductIdsOverrideProvider.notifier).setIds(next);
}

void revertOptimisticVaultToggle(
  WidgetRef ref, {
  required String productId,
  required bool wasSaving,
}) {
  final current = ref.read(displayVaultProductIdsProvider);
  final reverted = Set<String>.from(current);
  if (wasSaving) {
    reverted.remove(productId);
  } else {
    reverted.add(productId);
  }
  ref.read(vaultProductIdsOverrideProvider.notifier).setIds(reverted);
}

void clearVaultProductIdsOverride(WidgetRef ref) {
  ref.read(vaultProductIdsOverrideProvider.notifier).clear();
}
