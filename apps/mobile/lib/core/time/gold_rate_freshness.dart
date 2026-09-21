import 'server_clock.dart';

/// How fresh a displayed gold rate is.
enum GoldRateFreshness {
  fresh,
  stale,
  missingTimestamp,
  offlineCached,
}

/// Evaluates gold-rate staleness using server-adjusted time.
GoldRateFreshness evaluateGoldRateFreshness({
  required String? rateUpdatedAtIso,
  required ServerClock clock,
  required bool isOffline,
  required bool showingCachedRate,
  Duration staleAfter = const Duration(minutes: 15),
}) {
  if (isOffline && showingCachedRate) {
    return GoldRateFreshness.offlineCached;
  }

  if (rateUpdatedAtIso == null || rateUpdatedAtIso.trim().isEmpty) {
    return GoldRateFreshness.missingTimestamp;
  }

  final updatedAt = DateTime.tryParse(rateUpdatedAtIso.trim())?.toUtc();
  if (updatedAt == null) {
    return GoldRateFreshness.missingTimestamp;
  }

  final age = clock.nowUtc().difference(updatedAt);
  if (age > staleAfter) {
    return GoldRateFreshness.stale;
  }

  return GoldRateFreshness.fresh;
}
