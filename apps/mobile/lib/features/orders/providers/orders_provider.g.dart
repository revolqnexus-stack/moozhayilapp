// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ordersRepository)
const ordersRepositoryProvider = OrdersRepositoryProvider._();

final class OrdersRepositoryProvider
    extends
        $FunctionalProvider<
          OrdersRepository,
          OrdersRepository,
          OrdersRepository
        >
    with $Provider<OrdersRepository> {
  const OrdersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrdersRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrdersRepository create(Ref ref) {
    return ordersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrdersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrdersRepository>(value),
    );
  }
}

String _$ordersRepositoryHash() => r'e7b4cc2045f39c73f13ba006c6a01f8075e3a0a1';

@ProviderFor(ordersList)
const ordersListProvider = OrdersListFamily._();

final class OrdersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrdersListResponse>,
          OrdersListResponse,
          FutureOr<OrdersListResponse>
        >
    with
        $FutureModifier<OrdersListResponse>,
        $FutureProvider<OrdersListResponse> {
  const OrdersListProvider._({
    required OrdersListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ordersListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ordersListHash();

  @override
  String toString() {
    return r'ordersListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrdersListResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrdersListResponse> create(Ref ref) {
    final argument = this.argument as String;
    return ordersList(ref, status: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ordersListHash() => r'7dafd8c50002f4c555e0cf2f68663c0bee1b0af5';

final class OrdersListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OrdersListResponse>, String> {
  const OrdersListFamily._()
    : super(
        retry: null,
        name: r'ordersListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrdersListProvider call({String status = 'all'}) =>
      OrdersListProvider._(argument: status, from: this);

  @override
  String toString() => r'ordersListProvider';
}

@ProviderFor(orderDetail)
const orderDetailProvider = OrderDetailFamily._();

final class OrderDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrderDetailResponse>,
          OrderDetailResponse,
          FutureOr<OrderDetailResponse>
        >
    with
        $FutureModifier<OrderDetailResponse>,
        $FutureProvider<OrderDetailResponse> {
  const OrderDetailProvider._({
    required OrderDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderDetailHash();

  @override
  String toString() {
    return r'orderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrderDetailResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrderDetailResponse> create(Ref ref) {
    final argument = this.argument as String;
    return orderDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderDetailHash() => r'cc4e046c426063b37a5a5a02e7cfa8bc34f1b982';

final class OrderDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OrderDetailResponse>, String> {
  const OrderDetailFamily._()
    : super(
        retry: null,
        name: r'orderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderDetailProvider call(String orderId) =>
      OrderDetailProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderDetailProvider';
}

@ProviderFor(OrderActions)
const orderActionsProvider = OrderActionsProvider._();

final class OrderActionsProvider
    extends $AsyncNotifierProvider<OrderActions, void> {
  const OrderActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderActionsHash();

  @$internal
  @override
  OrderActions create() => OrderActions();
}

String _$orderActionsHash() => r'716dd4a91ca93601d5788dca73192eb0f1b94c5a';

abstract class _$OrderActions extends $AsyncNotifier<void> {
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
