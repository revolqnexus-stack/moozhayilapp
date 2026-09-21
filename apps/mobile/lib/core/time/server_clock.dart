/// Injectable clock aligned to server time when available.
///
/// [syncFromHttpDate] derives offset from the HTTP `Date` header.
/// When no server signal has been received, [nowUtc] uses device UTC and
/// [usesDeviceTimeFallback] is true — callers must treat staleness as approximate.
class ServerClock {
  ServerClock({DateTime Function()? deviceNow})
      : _deviceNow = deviceNow ?? (() => DateTime.now().toUtc());

  final DateTime Function() _deviceNow;

  Duration _offset = Duration.zero;
  bool _syncedFromServer = false;

  /// True until an HTTP `Date` header or explicit server instant is applied.
  bool get usesDeviceTimeFallback => !_syncedFromServer;

  Duration get offset => _offset;

  /// Current instant in UTC, adjusted by the last known server offset.
  DateTime nowUtc() => _deviceNow().add(_offset);

  /// Parses RFC 7231 HTTP-date and stores offset vs device UTC.
  void syncFromHttpDate(String? dateHeader) {
    if (dateHeader == null || dateHeader.trim().isEmpty) {
      return;
    }
    final parsed = _parseHttpDate(dateHeader.trim());
    if (parsed == null) {
      return;
    }
    _applyServerInstant(parsed);
  }

  void syncFromServerInstant(DateTime serverUtc) {
    _applyServerInstant(serverUtc.toUtc());
  }

  void _applyServerInstant(DateTime serverUtc) {
    _offset = serverUtc.difference(_deviceNow());
    _syncedFromServer = true;
  }

  void resetForTest() {
    _offset = Duration.zero;
    _syncedFromServer = false;
  }

  static DateTime? _parseHttpDate(String value) {
    try {
      return HttpHeaderDate.parse(value);
    } catch (_) {
      return DateTime.tryParse(value)?.toUtc();
    }
  }
}

/// Minimal RFC 7231 date parser (subset used in HTTP Date headers).
abstract final class HttpHeaderDate {
  static DateTime parse(String value) {
    final trimmed = value.trim();
    final asIso = DateTime.tryParse(trimmed);
    if (asIso != null) {
      return asIso.toUtc();
    }

    // IMF-fixdate: Sun, 06 Nov 1994 08:49:37 GMT
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final parts = trimmed.split(' ');
    if (parts.length < 5) {
      throw FormatException('Invalid HTTP date: $value');
    }

    final day = int.parse(parts[1]);
    final month = months[parts[2]] ?? 1;
    final year = int.parse(parts[3]);
    final timeParts = parts[4].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = int.parse(timeParts[2]);

    return DateTime.utc(year, month, day, hour, minute, second);
  }
}
