import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/features/orders/utils/order_timeline_mapper.dart';

void main() {
  group('orderTimelineCurrentStep', () {
    test('maps API order statuses to timeline indices', () {
      expect(orderTimelineCurrentStep('pending_payment'), 0);
      expect(orderTimelineCurrentStep('confirmed'), 1);
      expect(orderTimelineCurrentStep('shipped'), 2);
      expect(orderTimelineCurrentStep('delivered'), 3);
      expect(orderTimelineCurrentStep('cancelled'), 0);
    });
  });

  group('orderQualifiesForSuccessCelebration', () {
    test('allows celebration only for fulfilled payment states', () {
      expect(orderQualifiesForSuccessCelebration('confirmed'), isTrue);
      expect(orderQualifiesForSuccessCelebration('shipped'), isTrue);
      expect(orderQualifiesForSuccessCelebration('delivered'), isTrue);
      expect(orderQualifiesForSuccessCelebration('pending_payment'), isFalse);
      expect(orderQualifiesForSuccessCelebration('cancelled'), isFalse);
    });
  });
}
