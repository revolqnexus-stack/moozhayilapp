import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/time/gold_rate_freshness.dart';
import 'package:moozhayil/core/time/server_clock.dart';

void main() {
  ServerClock clockAt(DateTime deviceUtc) =>
      ServerClock(deviceNow: () => deviceUtc);

  test('fresh when updated within 15 minutes (server clock)', () {
    final device = DateTime.utc(2026, 3, 21, 10, 10);
    final clock = clockAt(device);
    clock.syncFromServerInstant(device);

    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
      clock: clock,
      isOffline: false,
      showingCachedRate: false,
    );

    expect(freshness, GoldRateFreshness.fresh);
  });

  test('stale when older than 15 minutes', () {
    final device = DateTime.utc(2026, 3, 21, 10, 20);
    final clock = clockAt(device);
    clock.syncFromServerInstant(device);

    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
      clock: clock,
      isOffline: false,
      showingCachedRate: false,
    );

    expect(freshness, GoldRateFreshness.stale);
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

  test('missing timestamp treated as stale/missing', () {
    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: null,
      clock: clockAt(DateTime.utc(2026, 3, 21, 10, 0)),
      isOffline: false,
      showingCachedRate: false,
    );

    expect(freshness, GoldRateFreshness.missingTimestamp);
  });

  test('device/server skew handled via clock offset', () {
    final device = DateTime.utc(2026, 3, 21, 9, 50);
    final clock = clockAt(device);
    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 10, 0));

    final freshness = evaluateGoldRateFreshness(
      rateUpdatedAtIso: '2026-03-21T09:50:00.000Z',
      clock: clock,
      isOffline: false,
      showingCachedRate: false,
    );

    expect(freshness, GoldRateFreshness.fresh);
  });
}
