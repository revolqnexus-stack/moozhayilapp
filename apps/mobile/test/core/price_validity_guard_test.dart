import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/pricing/price_validity_guard.dart';
import 'package:moozhayil/core/time/server_clock.dart';

void main() {
  test('remaining counts down from server anchor', () {
    final clock = ServerClock(
      deviceNow: () => DateTime.utc(2026, 3, 21, 12, 0),
    );
    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 12, 0));

    final guard = PriceValidityGuard(
      validUntilUtc: DateTime.utc(2026, 3, 21, 12, 15),
      serverTimeAtIssueUtc: DateTime.utc(2026, 3, 21, 12, 0),
      clock: clock,
    );

    expect(guard.remaining.inSeconds, inInclusiveRange(14 * 60 + 59, 15 * 60));
    expect(guard.isExpired, isFalse);
    expect(guard.isInFinalMinutes, isFalse);
  });

  test('isExpired when clock passes validUntil', () {
    final clock = ServerClock(
      deviceNow: () => DateTime.utc(2026, 3, 21, 12, 16),
    );
    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 12, 16));

    final guard = PriceValidityGuard(
      validUntilUtc: DateTime.utc(2026, 3, 21, 12, 15),
      serverTimeAtIssueUtc: DateTime.utc(2026, 3, 21, 12, 0),
      clock: clock,
    );

    expect(guard.isExpired, isTrue);
    expect(guard.remaining, Duration.zero);
  });

  test('isInFinalMinutes within last three minutes', () {
    final clock = ServerClock(
      deviceNow: () => DateTime.utc(2026, 3, 21, 12, 13),
    );
    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 12, 13));

    final guard = PriceValidityGuard(
      validUntilUtc: DateTime.utc(2026, 3, 21, 12, 15),
      serverTimeAtIssueUtc: DateTime.utc(2026, 3, 21, 12, 0),
      clock: clock,
    );

    expect(guard.isInFinalMinutes, isTrue);
    expect(guard.isExpired, isFalse);
  });
}
