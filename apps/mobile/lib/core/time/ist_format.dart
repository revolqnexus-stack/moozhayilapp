/// IST formatting with a fixed UTC+05:30 offset (India has no DST).
abstract final class IstFormat {
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Converts a UTC instant to wall-clock components in IST.
  static DateTime toIstWallClock(DateTime utcInstant) {
    final utc = utcInstant.toUtc();
    return DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
      utc.millisecond,
      utc.microsecond,
    ).add(istOffset);
  }

  /// "hh:mm a IST"
  static String formatTimeIst(DateTime utcInstant) {
    final ist = toIstWallClock(utcInstant);
    final hour24 = ist.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final amPm = hour24 >= 12 ? 'PM' : 'AM';
    final hourText = hour12.toString().padLeft(2, '0');
    final minute = ist.minute.toString().padLeft(2, '0');
    return '$hourText:$minute $amPm IST';
  }

  /// "as of hh:mm a, dd MMM IST"
  static String formatRateAsOf(DateTime utcInstant) {
    final ist = toIstWallClock(utcInstant);
    final hour24 = ist.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final amPm = hour24 >= 12 ? 'PM' : 'AM';
    final hourText = hour12.toString().padLeft(2, '0');
    final minute = ist.minute.toString().padLeft(2, '0');
    final month = _months[ist.month - 1];
    return 'as of $hourText:$minute $amPm, ${ist.day} $month IST';
  }
}
