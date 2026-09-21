/// Injectable clock aligned to server time when available.
///
/// After sync: `nowUtc = anchorUtc + max(stopwatch.elapsed, wall elapsed since sync)`.
/// Wall elapsed ensures sleep/lock-screen drift does not extend a countdown; a forward
/// device clock change may only make time look later (expire sooner), never extend it.
/// Before sync: falls back to [deviceNow].
class ServerClock {
  ServerClock({
    DateTime Function()? deviceNow,
    Stopwatch? stopwatch,
  })  : _deviceNow = deviceNow ?? (() => DateTime.now().toUtc()),
        _stopwatch = stopwatch ?? Stopwatch();

  final DateTime Function() _deviceNow;
  final Stopwatch _stopwatch;

  DateTime? _anchorUtc;
  DateTime? _syncWallUtc;
  bool _syncedFromServer = false;

  /// True until a non-cached HTTP `Date` header or explicit server instant is applied.
  bool get usesDeviceTimeFallback => !_syncedFromServer;

  DateTime? get anchorUtc => _anchorUtc;

  /// Current instant in UTC.
  DateTime nowUtc() {
    if (!_syncedFromServer || _anchorUtc == null || _syncWallUtc == null) {
      return _deviceNow();
    }
    final stopwatchElapsed = _stopwatch.elapsed;
    final wallElapsed = _deviceNow().difference(_syncWallUtc!);
    if (wallElapsed.isNegative) {
      // Device clock moved backward — do not shorten elapsed (expire sooner only via forward jumps).
      return _anchorUtc!.add(stopwatchElapsed);
    }
    final elapsed =
        stopwatchElapsed >= wallElapsed ? stopwatchElapsed : wallElapsed;
    return _anchorUtc!.add(elapsed);
  }

  /// Call on [AppLifecycleState.resumed] — clock is untrusted until the next sync.
  void markUnsyncedPendingResync() {
    _syncedFromServer = false;
    _anchorUtc = null;
    _syncWallUtc = null;
    _stopwatch.reset();
  }

  /// Parses RFC 7231 HTTP-date. Ignores cached responses ([ageHeader] present).
  void syncFromHttpDate(String? dateHeader, {String? ageHeader}) {
    if (ageHeader != null && ageHeader.trim().isNotEmpty) {
      return;
    }
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
    _anchorUtc = serverUtc;
    _syncWallUtc = _deviceNow();
    _stopwatch
      ..reset()
      ..start();
    _syncedFromServer = true;
  }

  void resetForTest() {
    _anchorUtc = null;
    _syncWallUtc = null;
    _stopwatch.reset();
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
