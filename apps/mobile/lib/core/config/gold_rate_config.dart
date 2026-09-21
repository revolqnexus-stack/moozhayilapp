/// Client fallback when the server omits [stale_after_seconds].
/// Production truth is server-provided via gold balance / rates API.
abstract final class GoldRateConfig {
  /// Labelled fallback only — matches API default until server field is present.
  static const Duration staleAfterFallback = Duration(hours: 8);
}
