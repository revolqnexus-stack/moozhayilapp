import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/time/server_clock.dart';

void main() {
  test('syncFromHttpDate anchors with max(stopwatch, wall elapsed)', () async {
    final stopwatch = Stopwatch();
    final clock = ServerClock(
      deviceNow: () => DateTime.utc(2099, 1, 1),
      stopwatch: stopwatch,
    );

    clock.syncFromHttpDate('Sat, 21 Mar 2026 10:05:00 GMT');
    stopwatch.start();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(clock.nowUtc().isAfter(DateTime.utc(2026, 3, 21, 10, 5)), isTrue);
  });

  test('forward device clock jump expires sooner (max wall elapsed)', () {
    var device = DateTime.utc(2026, 3, 21, 12, 0);
    final stopwatch = Stopwatch();
    final clock = ServerClock(deviceNow: () => device, stopwatch: stopwatch);

    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 12, 0));
    stopwatch.start();
    device = DateTime.utc(2026, 3, 21, 14, 0);
    expect(clock.nowUtc().hour, 14);
  });

  test('backward device clock does not shorten elapsed', () {
    var device = DateTime.utc(2026, 3, 21, 12, 0);
    final stopwatch = Stopwatch()..start();
    final clock = ServerClock(deviceNow: () => device, stopwatch: stopwatch);

    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 12, 0));
    stopwatch
      ..reset()
      ..start();
    device = DateTime.utc(2026, 3, 21, 10, 0);
    expect(clock.nowUtc().hour, 12);
    expect(clock.nowUtc().isBefore(DateTime.utc(2026, 3, 21, 12, 1)), isTrue);
  });

  test('markUnsyncedPendingResync falls back to device time', () {
    final device = DateTime.utc(2026, 1, 1, 12);
    final clock = ServerClock(deviceNow: () => device);
    clock.syncFromServerInstant(DateTime.utc(2026, 1, 1, 13));
    clock.markUnsyncedPendingResync();
    expect(clock.usesDeviceTimeFallback, isTrue);
    expect(clock.nowUtc(), device);
  });

  test('ignores Date header when Age header is present', () {
    final device = DateTime.utc(2026, 3, 21, 10, 0);
    final clock = ServerClock(deviceNow: () => device);

    clock.syncFromHttpDate('Sat, 21 Mar 2026 10:05:00 GMT', ageHeader: '120');

    expect(clock.usesDeviceTimeFallback, isTrue);
  });
}
