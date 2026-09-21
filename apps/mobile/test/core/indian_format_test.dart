import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/utils/indian_format.dart';

void main() {
  group('IndianFormat.formatInrPaise', () {
    test('formats zero', () {
      expect(IndianFormat.formatInrPaise(0), '₹0');
    });

    test('formats sub-thousand without grouping', () {
      expect(IndianFormat.formatInrPaise(999), '₹9');
      expect(IndianFormat.formatInrPaise(999, showPaise: true), '₹9.99');
    });

    test('formats thousands with Indian grouping', () {
      expect(IndianFormat.formatInrPaise(100000), '₹1,000');
      expect(IndianFormat.formatInrPaise(9999900), '₹99,999');
      expect(IndianFormat.formatInrPaise(10000000), '₹1,00,000');
    });

    test('formats lakhs and crores', () {
      expect(IndianFormat.formatInrPaise(1234567800), '₹1,23,45,678');
    });

    test('formats negative amounts', () {
      expect(IndianFormat.formatInrPaise(-50000), '-₹500');
      expect(IndianFormat.formatInrPaise(-1234567800), '-₹1,23,45,678');
    });

    test('shows paise when requested', () {
      expect(IndianFormat.formatInrPaise(100050, showPaise: true), '₹1,000.50');
      expect(IndianFormat.formatInrPaise(50, showPaise: true), '₹0.50');
    });
  });

  group('IndianFormat.formatGrams', () {
    test('floors to one decimal and never rounds up', () {
      expect(IndianFormat.formatGrams('0.99'), '0.9g');
      expect(IndianFormat.formatGrams('0.19'), '0.1g');
      expect(IndianFormat.formatGrams('1.99'), '1.9g');
    });

    test('formats whole and fractional grams', () {
      expect(IndianFormat.formatGrams('0'), '0.0g');
      expect(IndianFormat.formatGrams('37.45'), '37.4g');
    });

    test('prefers API display field when provided', () {
      expect(
        IndianFormat.formatGramsDisplay(
          display: '37.4g',
          rawGrams: '99.99',
        ),
        '37.4g',
      );
    });
  });

  group('IndianFormat.formatGramsDouble', () {
    test('floors animated double values', () {
      expect(IndianFormat.formatGramsDouble(0.99), '0.9g');
      expect(IndianFormat.formatGramsDouble(0.9999), '0.9g');
    });
  });

  group('IndianFormat.formatGramsPercentOf', () {
    test('computes floored partial weight', () {
      expect(
        IndianFormat.formatGramsPercentOf('10.0', 50),
        '5.0g',
      );
      expect(
        IndianFormat.formatGramsPercentOf('10.0', 0),
        '0.0g',
      );
    });
  });
}
