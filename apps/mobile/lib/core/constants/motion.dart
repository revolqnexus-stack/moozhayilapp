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

  // ── Component durations ───────────────────────────────────────────────────

  /// Primary/secondary button scale-down on press.
  static const Duration buttonPress = Duration(milliseconds: 80);

  /// Button fill/border colour change between enabled, pressed and loading.
  static const Duration buttonStateChange = Duration(milliseconds: 150);

  /// Product card fade-up entrance in grids.
  static const Duration cardReveal = Duration(milliseconds: 200);

  /// Dream Vault icon outline ↔ filled swap while saving.
  static const Duration vaultIconSwap = Duration(milliseconds: 200);

  /// Offline banner slide in from the top edge.
  static const Duration bannerSlide = Duration(milliseconds: 200);

  /// Progress ring / linear progress bar / goal ring fill.
  static const Duration progressFill = Duration(milliseconds: 800);

  /// Number count-up (gold value, grams, rupee amounts).
  static const Duration countUp = Duration(milliseconds: 400);

  /// One sweep of the gold shimmer / loading skeleton highlight.
  static const Duration shimmerCycle = Duration(milliseconds: 1200);

  /// Order timeline overall reveal.
  static const Duration timelineReveal = Duration(milliseconds: 500);

  /// Order timeline step icon state change.
  static const Duration timelineStepChange = Duration(milliseconds: 300);

  // ── Feature sequences ─────────────────────────────────────────────────────

  /// Gold seal + tick draw (payment success, KYC approved).
  static const Duration sealDraw = Duration(milliseconds: 700);

  /// Product image flight into the bag icon.
  static const Duration cartFlight = Duration(milliseconds: 500);

  /// Grams credited count-up with shimmer.
  static const Duration gramsCredit = Duration(milliseconds: 600);

  /// Wishlist heart molten-gold fill.
  static const Duration wishlistHeartFill = Duration(milliseconds: 400);

  /// Vault opening when a scheme matures or goal completes.
  static const Duration vaultOpen = Duration(milliseconds: 1000);

  /// Product shrinking into a vault card.
  static const Duration vaultAdd = Duration(milliseconds: 500);

  /// One rotation of the payment processing ring.
  static const Duration paymentProcessingCycle = Duration(milliseconds: 1500);

  /// One cycle of the Aura thinking line.
  static const Duration auraThinking = Duration(milliseconds: 1200);

  /// Gold rate digit roll.
  static const Duration rateRoll = Duration(milliseconds: 300);

  /// Small horizontal shake on a rejected input (wrong OTP).
  static const Duration errorShake = Duration(milliseconds: 360);

  /// Gold rate alert bell ring.
  static const Duration rateAlert = Duration(milliseconds: 400);

  // ── Curves ────────────────────────────────────────────────────────────────
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve press = Curves.easeOut;
  static const Curve exit = Curves.easeInCubic;

  /// Symmetric ease for state changes that start and end at rest
  /// (progress rings, banners, cart flight).
  static const Curve standardInOut = Curves.easeInOutCubic;

  /// Gentle settle for counters and rolling digits.
  static const Curve decelerate = Curves.easeOut;

  /// Slow, liquid ease for gold filling a goal ring.
  static const Curve organic = Curves.easeInOutSine;

  // ── Distances ─────────────────────────────────────────────────────────────
  static const double revealOffsetY = 28.0;
  static const double pressScale = 0.96;
  static const double cardPressScale = 0.94;
  static const double navActiveScale = 1.14;
  static const double heroImageScaleMax = 1.04;
}
