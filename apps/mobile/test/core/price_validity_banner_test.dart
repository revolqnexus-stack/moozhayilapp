import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/constants/customer_copy.dart';
import 'package:moozhayil/core/pricing/price_validity_guard.dart';
import 'package:moozhayil/core/time/server_clock.dart';
import 'package:moozhayil/core/widgets/price_validity_banner.dart';

void main() {
  testWidgets('shows expired copy and refresh action', (tester) async {
    final clock = ServerClock(
      deviceNow: () => DateTime.utc(2026, 3, 21, 12, 20),
    );
    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 12, 20));

    final guard = PriceValidityGuard(
      validUntilUtc: DateTime.utc(2026, 3, 21, 12, 15),
      serverTimeAtIssueUtc: DateTime.utc(2026, 3, 21, 12, 0),
      clock: clock,
    );

    var refreshed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PriceValidityBanner(
            guard: guard,
            onRefresh: () => refreshed = true,
          ),
        ),
      ),
    );

    expect(find.text(CustomerCopy.priceLockExpired), findsOneWidget);
    expect(find.text(CustomerCopy.priceLockRefresh), findsOneWidget);

    await tester.tap(find.text(CustomerCopy.priceLockRefresh));
    expect(refreshed, isTrue);
  });
}
