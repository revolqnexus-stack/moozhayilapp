import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/time/ist_format.dart';

void main() {
  test('formats IST with fixed +05:30 regardless of device timezone', () {
    // 2026-03-21 05:12 UTC → 10:42 IST
    final utc = DateTime.utc(2026, 3, 21, 5, 12);
    expect(
      IstFormat.formatRateAsOf(utc),
      'as of 10:42 AM, 21 Mar IST',
    );
  });

  test('toIstWallClock adds five hours thirty minutes', () {
    final utc = DateTime.utc(2026, 6, 1, 0, 0);
    final ist = IstFormat.toIstWallClock(utc);
    expect(ist.hour, 5);
    expect(ist.minute, 30);
  });
}
