import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/utils/indian_format.dart';

/// Mirrors [formatPaise] in apps/api/src/utils/money.ts:
/// `Intl.NumberFormat("en-IN")` on whole rupees from integer paise.
String apiFormatPaise(int amountPaise) {
  final rupees = amountPaise ~/ 100;
  final grouped = _groupEnIn(rupees);
  return '₹$grouped';
}

String _groupEnIn(int rupees) {
  final text = rupees.abs().toString();
  if (text.length <= 3) {
    return rupees.isNegative ? '-$text' : text;
  }
  final lastThree = text.substring(text.length - 3);
  final leading = text.substring(0, text.length - 3);
  final groups = <String>[];
  for (var index = leading.length; index > 0; index -= 2) {
    final start = index - 2 < 0 ? 0 : index - 2;
    groups.insert(0, leading.substring(start, index));
  }
  final grouped = '${groups.join(',')},$lastThree';
  return rupees.isNegative ? '-$grouped' : grouped;
}

void main() {
  test('client formatInrPaise matches API en-IN grouping at 1 lakh+', () {
    const cases = <int>[
      9789911, // products.integration.test.ts fixture → ₹97,899
      12345600, // ₹1,23,456
      1234567800, // ₹1,23,45,678
    ];

    for (final paise in cases) {
      expect(
        IndianFormat.formatInrPaise(paise),
        apiFormatPaise(paise),
        reason: 'paise=$paise',
      );
    }
  });
}
