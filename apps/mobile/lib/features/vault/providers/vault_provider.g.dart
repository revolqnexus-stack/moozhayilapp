// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vaultRepository)
const vaultRepositoryProvider = VaultRepositoryProvider._();

final class VaultRepositoryProvider
    extends
        $FunctionalProvider<VaultRepository, VaultRepository, VaultRepository>
    with $Provider<VaultRepository> {
  const VaultRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultRepositoryHash();

  @$internal
  @override
  $ProviderElement<VaultRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VaultRepository create(Ref ref) {
    return vaultRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultRepository>(value),
    );
  }
}

String _$vaultRepositoryHash() => r'3683a242f465b43410acbe0b2098bd320f67dc6e';

@ProviderFor(vaultItems)
const vaultItemsProvider = VaultItemsProvider._();

final class VaultItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<VaultListResponse>,
          VaultListResponse,
          FutureOr<VaultListResponse>
        >
    with
        $FutureModifier<VaultListResponse>,
        $FutureProvider<VaultListResponse> {
  const VaultItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultItemsHash();

  @$internal
  @override
  $FutureProviderElement<VaultListResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VaultListResponse> create(Ref ref) {
    return vaultItems(ref);
  }
}

String _$vaultItemsHash() => r'59b918761c6e13e741266400ff62909becd69c54';

@ProviderFor(vaultProductIds)
const vaultProductIdsProvider = VaultProductIdsProvider._();

final class VaultProductIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  const VaultProductIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultProductIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultProductIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return vaultProductIds(ref);
  }
}

String _$vaultProductIdsHash() => r'2b66e385108dbb06c0f899d51a21c2c983acd755';

@ProviderFor(GuestVaultStore)
const guestVaultStoreProvider = GuestVaultStoreProvider._();

final class GuestVaultStoreProvider
    extends $AsyncNotifierProvider<GuestVaultStore, Set<String>> {
  const GuestVaultStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guestVaultStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guestVaultStoreHash();

  @$internal
  @override
  GuestVaultStore create() => GuestVaultStore();
}

String _$guestVaultStoreHash() => r'220e96fd18e9bf521e30775ef84972fed39625f0';

abstract class _$GuestVaultStore extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(effectiveVaultProductIds)
const effectiveVaultProductIdsProvider = EffectiveVaultProductIdsProvider._();

final class EffectiveVaultProductIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  const EffectiveVaultProductIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveVaultProductIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveVaultProductIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return effectiveVaultProductIds(ref);
  }
}

String _$effectiveVaultProductIdsHash() =>
    r'9aa05d7ca886f8da01aae33884c10bfa2c7f2931';

@ProviderFor(VaultActions)
const vaultActionsProvider = VaultActionsProvider._();

final class VaultActionsProvider
    extends $AsyncNotifierProvider<VaultActions, void> {
  const VaultActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultActionsHash();

  @$internal
  @override
  VaultActions create() => VaultActions();
}

String _$vaultActionsHash() => r'ab6b61bd9a314e7af40e74c2dbc061128882ce7d';

abstract class _$VaultActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
