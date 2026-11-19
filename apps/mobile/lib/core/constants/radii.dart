/// All border-radius tokens for Moozhayil Gold & Diamonds.
/// Source: 02-design-system.md
/// Rule: Never use raw double literals for border radius — always reference AppRadius.*.
///
/// Premium upgrade: corners are softly rounded (not square) to feel like
/// a jewellery maison — precise, unhurried, tactile. The only fully sharp
/// corners are editorial panels that intentionally reference paper edges.
abstract final class AppRadius {
  // ── Base scale ────────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 999.0;

  // ── Semantic uses ─────────────────────────────────────────────────────────
  /// Editorial cards — soft radius, tactile like a velvet box lid.
  static const double card = 16.0;

  /// Primary / secondary CTAs — pill-soft but not circular.
  static const double button = 12.0;

  /// Chips and badges — gently rounded.
  static const double chip = 20.0;

  /// Input fields — matches button softness.
  static const double input = 12.0;

  /// Bottom sheets — soft top corners.
  static const double bottomSheet = 20.0;

  /// Product image thumbnails — subtle corner, never fully round.
  static const double productImage = 8.0;

  /// Editorial showcase carousel cards — soft corners for portfolio feel.
  static const double showcaseCard = 24.0;

  /// Detail-screen image thumbnails — the single allowed soft corner.
  static const double thumbnail = 2.0;

  /// Input fields and chips — gently rounded.
  static const double field = 10.0;
}
