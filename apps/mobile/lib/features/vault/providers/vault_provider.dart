import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/vault_item.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'vault_provider.g.dart';

class VaultRepository {
  const VaultRepository(this._apiService);

  final ApiService _apiService;

  void _normalizeProductMaps(Map<String, dynamic> raw) {
    void walk(dynamic node) {
      if (node is Map<String, dynamic>) {
        final weight = node['weight_grams'];
        if (weight is num) {
          node['weight_grams'] = weight.toString();
        }
        for (final value in node.values) {
          walk(value);
        }
      } else if (node is List) {
        for (final value in node) {
          walk(value);
        }
      }
    }

    walk(raw);
  }

  VaultListResponse _parseList(Map<String, dynamic> raw) {
    _normalizeProductMaps(raw);
    try {
      return VaultListResponse.fromJson(raw);
    } on Object catch (_) {
      throw const ApiException(
        'We couldn\u2019t load your Dream Vault. Please try again.',
      );
    }
  }

  AddVaultResponse _parseAdd(Map<String, dynamic> raw) {
    _normalizeProductMaps(raw);
    try {
      return AddVaultResponse.fromJson(raw);
    } on Object catch (_) {
      throw const ApiException(
        'We couldn\u2019t save to your Dream Vault. Please try again.',
      );
    }
  }

  Future<VaultListResponse> list() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/vault',
      );
      return _parseList(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AddVaultResponse> add(String productId) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/vault',
        data: {'product_id': productId},
      );
      return _parseAdd(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> remove(String itemId) async {
    try {
      await _apiService.client.delete<void>('/vault/$itemId');
    } on DioException catch (error) {
      final apiError = ApiException.fromDio(error);
      if (apiError.code == 'NOT_FOUND') {
        return;
      }
      throw apiError;
    }
  }

  Future<void> removeByProductId(String productId) async {
    try {
      await _apiService.client.delete<void>('/vault/products/$productId');
    } on DioException catch (error) {
      final apiError = ApiException.fromDio(error);
      if (apiError.code == 'NOT_FOUND') {
        return;
      }
      throw apiError;
    }
  }
}

@riverpod
VaultRepository vaultRepository(Ref ref) {
  return VaultRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<VaultListResponse> vaultItems(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step != AuthFlowStep.signedIn) {
    return const VaultListResponse(items: [], count: 0);
  }

  return ref.watch(vaultRepositoryProvider).list();
}

@riverpod
Future<Set<String>> vaultProductIds(Ref ref) async {
  final vault = await ref.watch(vaultItemsProvider.future);
  return vault.items.map((item) => item.product.id).toSet();
}

@riverpod
class GuestVaultStore extends _$GuestVaultStore {
  static const _boxName = 'guest_vault_product_ids';
  static const _idsKey = 'pending_ids';
  static const _syncedKey = 'synced';

  @override
  Future<Set<String>> build() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    final ids = box.get(_idsKey);
    if (ids is List) {
      return ids.whereType<String>().toSet();
    }
    return {};
  }

  Future<void> add(String productId) async {
    final current = {...(state.value ?? await future)};
    current.add(productId);
    await _persist(current);
    state = AsyncData(current);
  }

  Future<void> remove(String productId) async {
    final current = {...(state.value ?? await future)};
    current.remove(productId);
    await _persist(current);
    state = AsyncData(current);
  }

  Future<void> markSynced() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    await box.put(_syncedKey, true);
    await box.delete(_idsKey);
    state = const AsyncData({});
  }

  Future<bool> isSynced() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    return box.get(_syncedKey) == true;
  }

  Future<void> _persist(Set<String> ids) async {
    final box = await Hive.openBox<dynamic>(_boxName);
    await box.put(_idsKey, ids.toList(growable: false));
    await box.delete(_syncedKey);
  }
}

@riverpod
Future<Set<String>> effectiveVaultProductIds(Ref ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.value?.step == AuthFlowStep.signedIn) {
    return ref.watch(vaultProductIdsProvider.future);
  }
  return ref.watch(guestVaultStoreProvider.future);
}

@riverpod
class VaultActions extends _$VaultActions {
  @override
  FutureOr<void> build() {}

  Future<AddVaultResponse?> saveProduct(String productId) async {
    final auth = ref.read(authControllerProvider).value;
    if (auth?.step != AuthFlowStep.signedIn) {
      await ref.read(guestVaultStoreProvider.notifier).add(productId);
      return null;
    }

    try {
      final response = await ref.read(vaultRepositoryProvider).add(productId);
      ref.invalidate(vaultItemsProvider);
      ref.invalidate(vaultProductIdsProvider);
      return response;
    } on ApiException catch (error) {
      if (error.code == 'CONFLICT') {
        ref.invalidate(vaultItemsProvider);
        return null;
      }
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    await ref.read(vaultRepositoryProvider).remove(itemId);
    ref.invalidate(vaultItemsProvider);
    ref.invalidate(vaultProductIdsProvider);
  }

  Future<void> syncGuestVaultAfterAuth() async {
    final pending = await ref.read(guestVaultStoreProvider.future);
    if (pending.isEmpty) {
      return;
    }

    final repository = ref.read(vaultRepositoryProvider);
    for (final productId in pending) {
      try {
        await repository.add(productId);
      } on ApiException catch (error) {
        if (error.code != 'CONFLICT') {
          rethrow;
        }
      }
    }

    await ref.read(guestVaultStoreProvider.notifier).markSynced();
    ref.invalidate(vaultItemsProvider);
    ref.invalidate(vaultProductIdsProvider);
    ref.invalidate(guestVaultStoreProvider);
  }

  Future<void> removeProduct(String productId) async {
    final auth = ref.read(authControllerProvider).value;
    if (auth?.step != AuthFlowStep.signedIn) {
      await ref.read(guestVaultStoreProvider.notifier).remove(productId);
      ref.invalidate(effectiveVaultProductIdsProvider);
      return;
    }

    await ref.read(vaultRepositoryProvider).removeByProductId(productId);
    ref.invalidate(vaultItemsProvider);
    ref.invalidate(vaultProductIdsProvider);
    ref.invalidate(effectiveVaultProductIdsProvider);
  }

  Future<bool> toggleProduct(String productId) async {
    final ids = await ref.read(effectiveVaultProductIdsProvider.future);
    if (ids.contains(productId)) {
      await removeProduct(productId);
      return false;
    }

    await saveProduct(productId);
    return true;
  }
}
