import '../time/server_clock.dart';

/// Pure countdown helper for a server-issued price lock.
class PriceValidityGuard {
  PriceValidityGuard({
    required this.validUntilUtc,
    required this.serverTimeAtIssueUtc,
    required this.clock,
  });

  final DateTime validUntilUtc;
  final DateTime serverTimeAtIssueUtc;
  final ServerClock clock;

  Duration get remaining {
    final left = validUntilUtc.difference(clock.nowUtc());
    if (left.isNegative) {
      return Duration.zero;
    }
    return left;
  }

  bool get isExpired => remaining == Duration.zero;

  bool get isInFinalMinutes =>
      !isExpired && remaining <= const Duration(minutes: 3);

  bool get hasValidUntil =>
      validUntilUtc.isAfter(DateTime.fromMillisecondsSinceEpoch(0));
}
