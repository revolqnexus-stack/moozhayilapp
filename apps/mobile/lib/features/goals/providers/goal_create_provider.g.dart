// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_create_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GoalCreateDraftStore)
const goalCreateDraftStoreProvider = GoalCreateDraftStoreProvider._();

final class GoalCreateDraftStoreProvider
    extends $NotifierProvider<GoalCreateDraftStore, GoalCreateDraft> {
  const GoalCreateDraftStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalCreateDraftStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalCreateDraftStoreHash();

  @$internal
  @override
  GoalCreateDraftStore create() => GoalCreateDraftStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalCreateDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalCreateDraft>(value),
    );
  }
}

String _$goalCreateDraftStoreHash() =>
    r'4f95b95b1266f1c8a51fccc9b553524839f04840';

abstract class _$GoalCreateDraftStore extends $Notifier<GoalCreateDraft> {
  GoalCreateDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<GoalCreateDraft, GoalCreateDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GoalCreateDraft, GoalCreateDraft>,
              GoalCreateDraft,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
