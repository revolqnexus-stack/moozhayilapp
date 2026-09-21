import '../config/gold_rate_config.dart';
import 'server_clock.dart';

/// How fresh a displayed gold rate is.
enum GoldRateFreshness {
  fresh,

  /// Server says today's rate has not been republished (refresh cannot help).
  sourceStale,

  /// Refetch completed but server still reports the same stale rate.
  sourceUnchanged,

  /// Offline or local cache is older than expected (refresh may help).
  clientCacheStale,
  missingTimestamp,
  offlineCached,
}

/// Evaluates gold-rate display state. Prefers server [serverIsStale] when present.
GoldRateFreshness evaluateGoldRateFreshness({
  required String? rateUpdatedAtIso,
  required ServerClock clock,
  required bool isOffline,
  required bool showingCachedRate,
  bool? serverIsStale,
  bool refetchReturnedSameStaleRate = false,
  Duration staleAfter = GoldRateConfig.staleAfterFallback,
}) {
  if (isOffline && showingCachedRate) {
    return GoldRateFreshness.offlineCached;
  }

  if (rateUpdatedAtIso == null || rateUpdatedAtIso.trim().isEmpty) {
    return GoldRateFreshness.missingTimestamp;
  }

  if (serverIsStale == true) {
    if (refetchReturnedSameStaleRate) {
      return GoldRateFreshness.sourceUnchanged;
    }
    return GoldRateFreshness.sourceStale;
  }

  final updatedAt = DateTime.tryParse(rateUpdatedAtIso.trim())?.toUtc();
  if (updatedAt == null) {
    return GoldRateFreshness.missingTimestamp;
  }

  // Fallback only when server did not send is_stale (legacy responses).
  if (serverIsStale == null) {
    final age = clock.nowUtc().difference(updatedAt);
    if (age > staleAfter) {
      return GoldRateFreshness.clientCacheStale;
    }
  }

  return GoldRateFreshness.fresh;
}
