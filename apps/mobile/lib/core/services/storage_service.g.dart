// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureStorage)
const secureStorageProvider = SecureStorageProvider._();

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  const SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'd236803f715ed93447aac62dad02fd72721571b1';

@ProviderFor(storageService)
const storageServiceProvider = StorageServiceProvider._();

final class StorageServiceProvider
    extends $FunctionalProvider<StorageService, StorageService, StorageService>
    with $Provider<StorageService> {
  const StorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageServiceHash();

  @$internal
  @override
  $ProviderElement<StorageService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StorageService create(Ref ref) {
    return storageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageService>(value),
    );
  }
}

String _$storageServiceHash() => r'e5c556aee98a6032ce1ff43469e04db23a265e28';
