import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_service.g.dart';

class StorageService {
  StorageService(this._storage);

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';

  final FlutterSecureStorage _storage;

  /// Called after tokens are wiped (e.g. to refresh auth router state).
  void Function()? onTokensCleared;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    onTokensCleared?.call();
  }
}

@riverpod
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

@riverpod
StorageService storageService(Ref ref) {
  return StorageService(ref.watch(secureStorageProvider));
}
