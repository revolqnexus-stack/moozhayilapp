import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/models/kyc_status.dart';
import 'package:moozhayil/features/goals/providers/goals_provider.dart';
import 'package:moozhayil/features/goals/screens/contribute_screen.dart';
import 'package:moozhayil/features/profile/providers/kyc_provider.dart';

void main() {
  testWidgets('contribute shows KYC gate for unverified users before API', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kycStatusProvider.overrideWith(
            (ref) async => const KycStatusResponse(kycStatus: 'not_started'),
          ),
          goalsRepositoryProvider.overrideWith(
            (ref) => throw StateError('contribute must not be called'),
          ),
        ],
        child: const MaterialApp(
          home: ContributeScreen(goalId: 'goal-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Contribute now'));
    await tester.pumpAndSettle();

    expect(find.text('Verify to contribute to your Scheme'), findsOneWidget);
  });
}
