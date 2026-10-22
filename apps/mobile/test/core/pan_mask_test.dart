import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/utils/pan_mask.dart';

void main() {
  test('maskPan hides middle digits', () {
    expect(maskPan('ABCDE1234F'), 'ABCDE••••F');
  });
}
