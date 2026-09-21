/// Indian currency and gold-gram formatting (BR-PRICE-004, BR-BALANCE-003).
///
/// Money is always integer paise. Grams use fixed-point micro-units (4 decimal
/// places internally) with floor-to-1-decimal display — never round up.
abstract final class IndianFormat {
  static const String rupeeSymbol = '\u20B9';

  /// Formats [paise] as INR with Indian digit grouping (e.g. ₹12,34,567).
  ///
  /// [showPaise] when true appends two decimal places from the paise remainder.
  static String formatInrPaise(int paise, {bool showPaise = false}) {
    final negative = paise < 0;
    final absPaise = paise.abs();
    final rupees = absPaise ~/ 100;
    final remainder = absPaise % 100;

    final grouped = _groupIndianDigits(rupees.toString());
    final sign = negative ? '-' : '';
    final base = '$sign$rupeeSymbol$grouped';

    if (!showPaise) {
      return base;
    }

    final paiseText = remainder.toString().padLeft(2, '0');
    return '$base.$paiseText';
  }

  /// Prefer [display] from the API when present; otherwise floor-format [rawGrams].
  static String formatGramsDisplay({
    required String? display,
    required String rawGrams,
    bool includeSuffix = true,
  }) {
    if (display != null && display.trim().isNotEmpty) {
      return display.trim();
    }
    return formatGrams(rawGrams, includeSuffix: includeSuffix);
  }

  /// Floors [gramsRaw] to one decimal place with optional `g` suffix.
  static String formatGrams(String gramsRaw, {bool includeSuffix = true}) {
    return formatGramsFromMicro(
      parseGramsToMicro4(gramsRaw),
      includeSuffix: includeSuffix,
    );
  }

  /// Parses a gram quantity string into 4-decimal fixed-point micro-units.
  static int parseGramsToMicro4(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    final negative = trimmed.startsWith('-');
    final value = negative ? trimmed.substring(1) : trimmed;
    final parts = value.split('.');
    final whole = int.tryParse(parts.first) ?? 0;
    final fraction = parts.length > 1 ? parts[1] : '';
    final fractionPadded = '${fraction}0000'.substring(0, 4);
    final frac = int.tryParse(fractionPadded) ?? 0;
    final micro = whole * 10000 + frac;
    return negative ? -micro : micro;
  }

  /// Formats [gramsMicro4] (4 decimal fixed-point) to one decimal, floored.
  static String formatGramsFromMicro(
    int gramsMicro4, {
    bool includeSuffix = true,
  }) {
    final negative = gramsMicro4 < 0;
    final abs = gramsMicro4.abs();
    final tenths = abs ~/ 1000;
    final whole = tenths ~/ 10;
    final fractionDigit = tenths % 10;
    final sign = negative ? '-' : '';
    final body = '$sign$whole.$fractionDigit';
    return includeSuffix ? '${body}g' : body;
  }

  /// Floors [grams] to one decimal via string truncation — never `floor(x * 10^n)`.
  static String formatGramsDouble(double grams, {bool includeSuffix = true}) {
    return formatGrams(
      doubleToGramsRawTruncated(grams),
      includeSuffix: includeSuffix,
    );
  }

  /// Truncates a [double] to [maxFractionDigits] decimal places as a decimal string.
  static String doubleToGramsRawTruncated(
    double grams, {
    int maxFractionDigits = 4,
  }) {
    if (grams.isNaN || grams.isInfinite) {
      return '0';
    }

    final negative = grams < 0;
    final absText = grams.abs().toString();
    if (absText.contains('e') || absText.contains('E')) {
      return negative ? '-0' : '0';
    }

    final truncated = _truncateDecimalString(absText, maxFractionDigits);
    return negative ? '-$truncated' : truncated;
  }

  static String _truncateDecimalString(
    String positiveDecimal,
    int maxFractionDigits,
  ) {
    final parts = positiveDecimal.split('.');
    final whole = parts.first;
    if (parts.length == 1) {
      return whole;
    }

    final fraction = parts[1];
    final truncated = fraction.length > maxFractionDigits
        ? fraction.substring(0, maxFractionDigits)
        : fraction;
    final trimmed = truncated.replaceAll(RegExp(r'0+$'), '');
    if (trimmed.isEmpty) {
      return whole;
    }
    return '$whole.$trimmed';
  }

  /// Computes a floored gram display from [weightGrams] and [percentComplete].
  static String formatGramsPercentOf(
    String weightGrams,
    int percentComplete, {
    bool includeSuffix = true,
  }) {
    final clamped = percentComplete.clamp(0, 100);
    if (clamped == 0) {
      return includeSuffix ? '0.0g' : '0.0';
    }
    final baseMicro = parseGramsToMicro4(weightGrams);
    final currentMicro = (baseMicro * clamped) ~/ 100;
    return formatGramsFromMicro(currentMicro, includeSuffix: includeSuffix);
  }

  static String _groupIndianDigits(String digits) {
    if (digits.length <= 3) {
      return digits;
    }

    final lastThree = digits.substring(digits.length - 3);
    final leading = digits.substring(0, digits.length - 3);
    final leadingGroups = <String>[];
    for (var index = leading.length; index > 0; index -= 2) {
      final start = index - 2 < 0 ? 0 : index - 2;
      leadingGroups.insert(0, leading.substring(start, index));
    }
    return '${leadingGroups.join(',')},$lastThree';
  }
}
