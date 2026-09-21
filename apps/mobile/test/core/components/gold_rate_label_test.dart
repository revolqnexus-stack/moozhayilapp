import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/components/gold_rate_label.dart';
import 'package:moozhayil/core/constants/customer_copy.dart';
import 'package:moozhayil/core/time/server_clock.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );
  }

  ServerClock freshClock() {
    final now = DateTime.utc(2026, 3, 21, 10, 5);
    final clock = ServerClock(deviceNow: () => now);
    clock.syncFromServerInstant(now);
    return clock;
  }

  testWidgets('shows fresh rate with IST timestamp', (tester) async {
    await tester.pumpWidget(
      wrap(
        GoldRateLabel(
          ratePaise: 725000,
          rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
          purityLabel: '22KT',
          clock: freshClock(),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(GoldRateLabel));
    expect(semantics.label, contains('7,250'));
    expect(semantics.label, contains('03:30 PM, 21 Mar IST'));
    expect(find.text(CustomerCopy.goldRateStale), findsNothing);
  });

  testWidgets('shows stale copy when rate is older than 15 minutes', (tester) async {
    final clock = ServerClock(deviceNow: () => DateTime.utc(2026, 3, 21, 10, 30));
    clock.syncFromServerInstant(DateTime.utc(2026, 3, 21, 10, 30));

    await tester.pumpWidget(
      wrap(
        GoldRateLabel(
          ratePaise: 725000,
          rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
          purityLabel: '22KT',
          clock: clock,
        ),
      ),
    );

    expect(find.text(CustomerCopy.goldRateStale), findsOneWidget);
    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
  });

  testWidgets('shows offline copy when offline cached', (tester) async {
    await tester.pumpWidget(
      wrap(
        GoldRateLabel(
          ratePaise: 725000,
          rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
          purityLabel: '22KT',
          clock: freshClock(),
          isOffline: true,
          showingCachedRate: true,
        ),
      ),
    );

    expect(find.text(CustomerCopy.goldRateOffline), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });

  testWidgets('shows refreshing copy only while refresh in flight', (tester) async {
    await tester.pumpWidget(
      wrap(
        GoldRateLabel(
          ratePaise: 725000,
          rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
          purityLabel: '22KT',
          clock: freshClock(),
          isRefreshing: true,
        ),
      ),
    );

    expect(find.text(CustomerCopy.goldRateRefreshing), findsOneWidget);
    expect(find.text(CustomerCopy.goldRateStale), findsNothing);
  });

  testWidgets('missing timestamp shows time unavailable', (tester) async {
    await tester.pumpWidget(
      wrap(
        GoldRateLabel(
          ratePaise: 725000,
          rateUpdatedAtIso: null,
          purityLabel: '22KT',
          clock: freshClock(),
        ),
      ),
    );

    expect(find.text(CustomerCopy.goldRateTimeUnavailable), findsWidgets);
  });

  testWidgets('semantics reads full sentence', (tester) async {
    await tester.pumpWidget(
      wrap(
        GoldRateLabel(
          ratePaise: 725000,
          rateUpdatedAtIso: '2026-03-21T10:00:00.000Z',
          purityLabel: '22KT',
          clock: freshClock(),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(GoldRateLabel));
    expect(
      semantics.label,
      contains('Gold rate ₹7,250/g per gram'),
    );
  });
}
