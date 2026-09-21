import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/routing/app_routes.dart';
import 'package:moozhayil/features/goals/providers/goal_create_provider.dart';

void main() {
  test('Crest and Dhanam require first-payment handoff', () {
    expect(GoldenWishSchemeType.crest.isLumpSum, isTrue);
    expect(GoldenWishSchemeType.dhanam.isRateProtected, isTrue);
    expect(GoldenWishSchemeType.aura.isLumpSum, isFalse);
    expect(GoldenWishSchemeType.goldNidhi.isRateProtected, isFalse);
  });

  test('goalContributeFirstPayment builds locked contribute route', () {
    final uri = Uri.parse(
      AppRoutes.goalContributeFirstPayment(
        goalId: 'goal-123',
        amountPaise: 500000,
      ),
    );
    expect(uri.path, '/goals/goal-123/contribute');
    expect(uri.queryParameters['firstPayment'], '1');
    expect(uri.queryParameters['amountPaise'], '500000');
  });
}
