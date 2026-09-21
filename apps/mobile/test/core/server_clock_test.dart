import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/time/server_clock.dart';

void main() {
  test('syncFromHttpDate applies offset vs injectable device clock', () {
    final device = DateTime.utc(2026, 3, 21, 10, 0);
    final clock = ServerClock(deviceNow: () => device);

    expect(clock.usesDeviceTimeFallback, isTrue);

    clock.syncFromHttpDate('Sat, 21 Mar 2026 10:05:00 GMT');

    expect(clock.usesDeviceTimeFallback, isFalse);
    expect(clock.nowUtc(), DateTime.utc(2026, 3, 21, 10, 5));
  });

  test('nowUtc falls back to device UTC when unsynced', () {
    final device = DateTime.utc(2026, 1, 1, 12);
    final clock = ServerClock(deviceNow: () => device);

    expect(clock.nowUtc(), device);
    expect(clock.usesDeviceTimeFallback, isTrue);
  });
}
