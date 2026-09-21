// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kycRepository)
const kycRepositoryProvider = KycRepositoryProvider._();

final class KycRepositoryProvider
    extends $FunctionalProvider<KycRepository, KycRepository, KycRepository>
    with $Provider<KycRepository> {
  const KycRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycRepositoryHash();

  @$internal
  @override
  $ProviderElement<KycRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KycRepository create(Ref ref) {
    return kycRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycRepository>(value),
    );
  }
}

String _$kycRepositoryHash() => r'c2bac0699b37ebcaad9ac8c7e6aa98deb74d42d4';

@ProviderFor(kycStatus)
const kycStatusProvider = KycStatusProvider._();

final class KycStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<KycStatusResponse>,
          KycStatusResponse,
          FutureOr<KycStatusResponse>
        >
    with
        $FutureModifier<KycStatusResponse>,
        $FutureProvider<KycStatusResponse> {
  const KycStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycStatusHash();

  @$internal
  @override
  $FutureProviderElement<KycStatusResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KycStatusResponse> create(Ref ref) {
    return kycStatus(ref);
  }
}

String _$kycStatusHash() => r'bcd818a199ece0fbc4ca86e8a0ac983f8ab71ebe';

@ProviderFor(KycFlowActions)
const kycFlowActionsProvider = KycFlowActionsProvider._();

final class KycFlowActionsProvider
    extends $AsyncNotifierProvider<KycFlowActions, void> {
  const KycFlowActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycFlowActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycFlowActionsHash();

  @$internal
  @override
  KycFlowActions create() => KycFlowActions();
}

String _$kycFlowActionsHash() => r'0d06f4eac5ca474c30ea0c330e3ccb3667f15bd5';

abstract class _$KycFlowActions extends $AsyncNotifier<void> {
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
