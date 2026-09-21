// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cartRepository)
const cartRepositoryProvider = CartRepositoryProvider._();

final class CartRepositoryProvider
    extends $FunctionalProvider<CartRepository, CartRepository, CartRepository>
    with $Provider<CartRepository> {
  const CartRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartRepositoryHash();

  @$internal
  @override
  $ProviderElement<CartRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CartRepository create(Ref ref) {
    return cartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartRepository>(value),
    );
  }
}

String _$cartRepositoryHash() => r'fe2e5cb9fb93a526941afb7bd0cd9a67b5936cef';

@ProviderFor(cartSummary)
const cartSummaryProvider = CartSummaryProvider._();

final class CartSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CartSummary>,
          CartSummary,
          FutureOr<CartSummary>
        >
    with $FutureModifier<CartSummary>, $FutureProvider<CartSummary> {
  const CartSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartSummaryHash();

  @$internal
  @override
  $FutureProviderElement<CartSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CartSummary> create(Ref ref) {
    return cartSummary(ref);
  }
}

String _$cartSummaryHash() => r'd028532f92131e93c910465f13b82674dd9b1044';

@ProviderFor(CartActions)
const cartActionsProvider = CartActionsProvider._();

final class CartActionsProvider
    extends $AsyncNotifierProvider<CartActions, void> {
  const CartActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartActionsHash();

  @$internal
  @override
  CartActions create() => CartActions();
}

String _$cartActionsHash() => r'43dcb287dd9c54c144fdfc5185727e0d72d0a0b9';

abstract class _$CartActions extends $AsyncNotifier<void> {
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
