// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goldBalanceRepository)
const goldBalanceRepositoryProvider = GoldBalanceRepositoryProvider._();

final class GoldBalanceRepositoryProvider
    extends
        $FunctionalProvider<
          GoldBalanceRepository,
          GoldBalanceRepository,
          GoldBalanceRepository
        >
    with $Provider<GoldBalanceRepository> {
  const GoldBalanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goldBalanceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goldBalanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoldBalanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoldBalanceRepository create(Ref ref) {
    return goldBalanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoldBalanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoldBalanceRepository>(value),
    );
  }
}

String _$goldBalanceRepositoryHash() =>
    r'f1c417d2cdbdde5a6ca4636aa5a8489240e2018a';

@ProviderFor(goldBalance)
const goldBalanceProvider = GoldBalanceProvider._();

final class GoldBalanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoldBalance>,
          GoldBalance,
          FutureOr<GoldBalance>
        >
    with $FutureModifier<GoldBalance>, $FutureProvider<GoldBalance> {
  const GoldBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goldBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goldBalanceHash();

  @$internal
  @override
  $FutureProviderElement<GoldBalance> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GoldBalance> create(Ref ref) {
    return goldBalance(ref);
  }
}

String _$goldBalanceHash() => r'0b6539b87705ab3c64787409d3ad3cecac43a0c3';

@ProviderFor(goldLedger)
const goldLedgerProvider = GoldLedgerProvider._();

final class GoldLedgerProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoldLedgerResponse>,
          GoldLedgerResponse,
          FutureOr<GoldLedgerResponse>
        >
    with
        $FutureModifier<GoldLedgerResponse>,
        $FutureProvider<GoldLedgerResponse> {
  const GoldLedgerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goldLedgerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goldLedgerHash();

  @$internal
  @override
  $FutureProviderElement<GoldLedgerResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GoldLedgerResponse> create(Ref ref) {
    return goldLedger(ref);
  }
}

String _$goldLedgerHash() => r'd84ea28b2bebb3156af3c94cbb94f0ea886028fd';

@ProviderFor(redeemableProducts)
const redeemableProductsProvider = RedeemableProductsProvider._();

final class RedeemableProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  const RedeemableProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'redeemableProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$redeemableProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    return redeemableProducts(ref);
  }
}

String _$redeemableProductsHash() =>
    r'732c9e6d7797b825b301736bdcfdc298a97b2e59';

@ProviderFor(pendingContributions)
const pendingContributionsProvider = PendingContributionsProvider._();

final class PendingContributionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PendingContributionsResponse>,
          PendingContributionsResponse,
          FutureOr<PendingContributionsResponse>
        >
    with
        $FutureModifier<PendingContributionsResponse>,
        $FutureProvider<PendingContributionsResponse> {
  const PendingContributionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingContributionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingContributionsHash();

  @$internal
  @override
  $FutureProviderElement<PendingContributionsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PendingContributionsResponse> create(Ref ref) {
    return pendingContributions(ref);
  }
}

String _$pendingContributionsHash() =>
    r'1b1366caa9c956c859853625dc14385ea69d21ab';
