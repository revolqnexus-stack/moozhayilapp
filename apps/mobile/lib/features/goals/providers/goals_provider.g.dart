// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalsRepository)
const goalsRepositoryProvider = GoalsRepositoryProvider._();

final class GoalsRepositoryProvider
    extends
        $FunctionalProvider<GoalsRepository, GoalsRepository, GoalsRepository>
    with $Provider<GoalsRepository> {
  const GoalsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoalsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalsRepository create(Ref ref) {
    return goalsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalsRepository>(value),
    );
  }
}

String _$goalsRepositoryHash() => r'a3a0e742f7ec16c9597c4ab061d9a4f24a1cd74c';

@ProviderFor(goalsList)
const goalsListProvider = GoalsListFamily._();

final class GoalsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoalsListResponse>,
          GoalsListResponse,
          FutureOr<GoalsListResponse>
        >
    with
        $FutureModifier<GoalsListResponse>,
        $FutureProvider<GoalsListResponse> {
  const GoalsListProvider._({
    required GoalsListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalsListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalsListHash();

  @override
  String toString() {
    return r'goalsListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GoalsListResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GoalsListResponse> create(Ref ref) {
    final argument = this.argument as String;
    return goalsList(ref, status: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalsListHash() => r'4d6af7d6c1062463bbe2b0d40a88ccaea8144a5a';

final class GoalsListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GoalsListResponse>, String> {
  const GoalsListFamily._()
    : super(
        retry: null,
        name: r'goalsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalsListProvider call({String status = 'all'}) =>
      GoalsListProvider._(argument: status, from: this);

  @override
  String toString() => r'goalsListProvider';
}

@ProviderFor(goalDetail)
const goalDetailProvider = GoalDetailFamily._();

final class GoalDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoalDetailResponse>,
          GoalDetailResponse,
          FutureOr<GoalDetailResponse>
        >
    with
        $FutureModifier<GoalDetailResponse>,
        $FutureProvider<GoalDetailResponse> {
  const GoalDetailProvider._({
    required GoalDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalDetailHash();

  @override
  String toString() {
    return r'goalDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GoalDetailResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GoalDetailResponse> create(Ref ref) {
    final argument = this.argument as String;
    return goalDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalDetailHash() => r'd257529c4b69bb913eb9974fa7bd6016557912a1';

final class GoalDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GoalDetailResponse>, String> {
  const GoalDetailFamily._()
    : super(
        retry: null,
        name: r'goalDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalDetailProvider call(String goalId) =>
      GoalDetailProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalDetailProvider';
}
