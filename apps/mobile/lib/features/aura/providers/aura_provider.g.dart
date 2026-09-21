// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aura_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(auraRepository)
const auraRepositoryProvider = AuraRepositoryProvider._();

final class AuraRepositoryProvider
    extends $FunctionalProvider<AuraRepository, AuraRepository, AuraRepository>
    with $Provider<AuraRepository> {
  const AuraRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auraRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auraRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuraRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuraRepository create(Ref ref) {
    return auraRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuraRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuraRepository>(value),
    );
  }
}

String _$auraRepositoryHash() => r'16e389a2e7871671a5738c35f4f3cf7edffa3c95';

@ProviderFor(auraInsight)
const auraInsightProvider = AuraInsightProvider._();

final class AuraInsightProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuraInsightResponse>,
          AuraInsightResponse,
          FutureOr<AuraInsightResponse>
        >
    with
        $FutureModifier<AuraInsightResponse>,
        $FutureProvider<AuraInsightResponse> {
  const AuraInsightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auraInsightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auraInsightHash();

  @$internal
  @override
  $FutureProviderElement<AuraInsightResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AuraInsightResponse> create(Ref ref) {
    return auraInsight(ref);
  }
}

String _$auraInsightHash() => r'004bc050faba49e87130a799d8e9ed850693a3dc';

@ProviderFor(AuraConversation)
const auraConversationProvider = AuraConversationFamily._();

final class AuraConversationProvider
    extends
        $AsyncNotifierProvider<
          AuraConversation,
          List<AuraConversationMessage>
        > {
  const AuraConversationProvider._({
    required AuraConversationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'auraConversationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$auraConversationHash();

  @override
  String toString() {
    return r'auraConversationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AuraConversation create() => AuraConversation();

  @override
  bool operator ==(Object other) {
    return other is AuraConversationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$auraConversationHash() => r'ab101b1515d89c6f6a961b5e0e3d07feb570f23a';

final class AuraConversationFamily extends $Family
    with
        $ClassFamilyOverride<
          AuraConversation,
          AsyncValue<List<AuraConversationMessage>>,
          List<AuraConversationMessage>,
          FutureOr<List<AuraConversationMessage>>,
          String
        > {
  const AuraConversationFamily._()
    : super(
        retry: null,
        name: r'auraConversationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuraConversationProvider call(String sessionId) =>
      AuraConversationProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'auraConversationProvider';
}

abstract class _$AuraConversation
    extends $AsyncNotifier<List<AuraConversationMessage>> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<List<AuraConversationMessage>> build(String sessionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AuraConversationMessage>>,
              List<AuraConversationMessage>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AuraConversationMessage>>,
                List<AuraConversationMessage>
              >,
              AsyncValue<List<AuraConversationMessage>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AuraActions)
const auraActionsProvider = AuraActionsProvider._();

final class AuraActionsProvider
    extends $AsyncNotifierProvider<AuraActions, void> {
  const AuraActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auraActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auraActionsHash();

  @$internal
  @override
  AuraActions create() => AuraActions();
}

String _$auraActionsHash() => r'f1dddaa282582852d0b8445bc2bdccb288bb47c8';

abstract class _$AuraActions extends $AsyncNotifier<void> {
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
