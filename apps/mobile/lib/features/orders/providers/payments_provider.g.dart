// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentsRepository)
const paymentsRepositoryProvider = PaymentsRepositoryProvider._();

final class PaymentsRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentsRepository,
          PaymentsRepository,
          PaymentsRepository
        >
    with $Provider<PaymentsRepository> {
  const PaymentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentsRepository create(Ref ref) {
    return paymentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentsRepository>(value),
    );
  }
}

String _$paymentsRepositoryHash() =>
    r'd1cc6b73d581b701627e3e15c96a455ecd3d2dc8';

@ProviderFor(paymentMethods)
const paymentMethodsProvider = PaymentMethodsProvider._();

final class PaymentMethodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentMethod>>,
          List<PaymentMethod>,
          FutureOr<List<PaymentMethod>>
        >
    with
        $FutureModifier<List<PaymentMethod>>,
        $FutureProvider<List<PaymentMethod>> {
  const PaymentMethodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentMethodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentMethodsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentMethod>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentMethod>> create(Ref ref) {
    return paymentMethods(ref);
  }
}

String _$paymentMethodsHash() => r'9b4fde16ed8933be4b63337f1c67f340dd6aa198';

@ProviderFor(PaymentMethodActions)
const paymentMethodActionsProvider = PaymentMethodActionsProvider._();

final class PaymentMethodActionsProvider
    extends $AsyncNotifierProvider<PaymentMethodActions, void> {
  const PaymentMethodActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentMethodActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentMethodActionsHash();

  @$internal
  @override
  PaymentMethodActions create() => PaymentMethodActions();
}

String _$paymentMethodActionsHash() =>
    r'eec106ce1f3a0c8aac304867d84a05d65a04efe7';

abstract class _$PaymentMethodActions extends $AsyncNotifier<void> {
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
