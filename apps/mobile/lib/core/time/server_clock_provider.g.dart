// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared server-adjusted clock for rate staleness and price validity (Fix 1).

@ProviderFor(serverClock)
const serverClockProvider = ServerClockProvider._();

/// Shared server-adjusted clock for rate staleness and price validity (Fix 1).

final class ServerClockProvider
    extends $FunctionalProvider<ServerClock, ServerClock, ServerClock>
    with $Provider<ServerClock> {
  /// Shared server-adjusted clock for rate staleness and price validity (Fix 1).
  const ServerClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverClockHash();

  @$internal
  @override
  $ProviderElement<ServerClock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServerClock create(Ref ref) {
    return serverClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerClock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerClock>(value),
    );
  }
}

String _$serverClockHash() => r'3305c9476050c05d8e503d96005e86648cb7520f';
