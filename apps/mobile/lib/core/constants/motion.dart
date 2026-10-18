import 'package:flutter/material.dart';

/// Centralized premium motion tokens for Moozhayil.
///
/// Use these instead of hardcoded durations/curves across screens.
abstract final class AppMotion {
  // ── Durations ─────────────────────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 380);
  static const Duration cinematic = Duration(milliseconds: 700);
  static const Duration hero = Duration(milliseconds: 1000);

  /// Stagger between consecutive section/list reveals.
  static const Duration staggerStep = Duration(milliseconds: 50);

  /// Card/button press compress duration.
  static const Duration pressDuration = Duration(milliseconds: 120);

  /// Icon/badge and small state changes.
  static const Duration stateTransition = fast;

  /// Sheets, dialogs, and content cross-fades.
  static const Duration contentTransition = normal;

  /// Major confirmation draw sequences (ring + check).
  static const Duration confirmationSequence = slow;

  /// Bottom nav indicator slide.
  static const Duration navIndicator = Duration(milliseconds: 220);

  /// Hero carousel page transition.
  static const Duration heroPage = Duration(milliseconds: 700);

  /// Dream Vault heart save sequence.
  static const Duration heartSave = Duration(milliseconds: 280);

  // ── Curves ────────────────────────────────────────────────────────────────
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve press = Curves.easeOut;
  static const Curve exit = Curves.easeInCubic;

  // ── Distances ─────────────────────────────────────────────────────────────
  static const double revealOffsetY = 28.0;
  static const double pressScale = 0.96;
  static const double cardPressScale = 0.94;
  static const double navActiveScale = 1.14;
  static const double heroImageScaleMax = 1.04;
}
