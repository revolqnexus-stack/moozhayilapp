import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/time/gold_rate_freshness.dart';
import 'package:moozhayil/core/time/server_clock.dart';

void main() {
  ServerClock clockAt(DateTime deviceUtc) =>
      ServerClock(deviceNow: () => deviceUtc);

  test('fresh when server reports is_stale false', () {
    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
      clock: clockAt(DateTime.utc(2026, 3, 21, 19, 0)),
      isOffline: false,
      showingCachedRate: false,
      serverIsStale: false,
    );
    expect(freshness, GoldRateFreshness.fresh);
  });

  test('sourceStale when server reports is_stale true', () {
    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
      clock: clockAt(DateTime.utc(2026, 3, 21, 19, 0)),
      isOffline: false,
      showingCachedRate: false,
      serverIsStale: true,
    );
    expect(freshness, GoldRateFreshness.sourceStale);
  });

  test('sourceUnchanged after refetch with same stale server flag', () {
    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
      clock: clockAt(DateTime.utc(2026, 3, 21, 19, 0)),
      isOffline: false,
      showingCachedRate: false,
      serverIsStale: true,
      refetchReturnedSameStaleRate: true,
    );
    expect(freshness, GoldRateFreshness.sourceUnchanged);
  });

  test('clientCacheStale fallback when server omits is_stale', () {
    final device = DateTime.utc(2026, 3, 21, 19, 0);
    final clock = clockAt(device);
    clock.syncFromServerInstant(device);

    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
      clock: clock,
      isOffline: false,
      showingCachedRate: false,
    );
    expect(freshness, GoldRateFreshness.clientCacheStale);
  });

  test('offline cached when offline and showing cached rate', () {
    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
      clock: clockAt(DateTime.utc(2026, 3, 21, 10, 5)),
      isOffline: true,
      showingCachedRate: true,
    );
    expect(freshness, GoldRateFreshness.offlineCached);
  });
}
