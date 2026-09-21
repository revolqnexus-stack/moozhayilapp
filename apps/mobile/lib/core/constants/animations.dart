import 'package:flutter/animation.dart';

/// Premium animation durations and curves for Moozhayil.
/// All animations feel jewellery-like: calm, precise, trustworthy.
/// Never bouncy, cartoonish, or game-like.
class AppAnimations {
  AppAnimations._();

  // ── Core durations ─────────────────────────────────────────────────────────
  static const instant = Duration(milliseconds: 0);
  static const xxs = Duration(milliseconds: 100);
  static const xs = Duration(milliseconds: 150);
  static const sm = Duration(milliseconds: 200);
  static const md = Duration(milliseconds: 300);
  static const lg = Duration(milliseconds: 400);
  static const xl = Duration(milliseconds: 500);
  static const xxl = Duration(milliseconds: 600);
  static const cinematic = Duration(milliseconds: 800);

  // ── Specialized durations ──────────────────────────────────────────────────
  static const buttonPress = Duration(milliseconds: 80);
  static const cardPress = Duration(milliseconds: 120);
  static const goldShimmer = Duration(milliseconds: 1200);
  static const sealDraw = Duration(milliseconds: 600);
  static const numberCounter = Duration(milliseconds: 400);
  static const progressFill = Duration(milliseconds: 800);
  static const vaultOpen = Duration(milliseconds: 1000);
  static const rateUpdate = Duration(milliseconds: 300);
  static const heroPage = Duration(milliseconds: 350);
  static const normal = Duration(milliseconds: 250);
  static const navIndicator = Duration(milliseconds: 280);
  static const goldCountUp = Duration(milliseconds: 400);
  static const shimmer = Duration(milliseconds: 1200);
  static const ringFill = Duration(milliseconds: 800);

  // ── Premium curves ─────────────────────────────────────────────────────────
  /// Standard ease for most transitions — smooth, precise
  static const standard = Curves.easeInOutCubic;

  /// Default curve used throughout the app
  static const curveDefault = Curves.easeInOutCubic;

  /// For things that settle naturally (cards, sheets)
  static const decelerate = Curves.easeOut;

  /// For things that start gently (flying products, drawing lines)
  static const accelerate = Curves.easeIn;

  /// For jewellery weight and prestige (vault open, seal stamp)
  static const emphasize = Curves.easeInOutQuart;

  /// For organic flows (gold pouring, grams crediting)
  static const organic = Curves.easeInOutSine;

  /// For counting numbers and ticking progress
  static const linear = Curves.linear;

  // ── Scale factors ──────────────────────────────────────────────────────────
  static const pressScale = 0.97;
  static const cardPressScale = 0.98;
  static const buttonPressScale = 0.96;
  static const navActiveScale = 1.05;
  static const heroImageScaleMax = 1.08;

  // ── Stagger delays ─────────────────────────────────────────────────────────
  static const staggerTiny = Duration(milliseconds: 40);
  static const staggerSmall = Duration(milliseconds: 60);
  static const staggerMedium = Duration(milliseconds: 80);
  static const staggerLarge = Duration(milliseconds: 120);
}

/// Premium animation presets for specific interactions.
class AnimationPresets {
  AnimationPresets._();

  // ── Purchase & Order animations ────────────────────────────────────────────

  /// Product image flies into cart icon
  static const addToCartFlight = Duration(milliseconds: 500);
  static const addToCartCurve = Curves.easeInOutCubic;

  /// Button compresses, then transitions to checkout
  static const buyNowPress = Duration(milliseconds: 100);
  static const buyNowTransition = Duration(milliseconds: 350);

  /// Rotating gold ring or gemstone shimmer
  static const paymentProcessing = Duration(milliseconds: 1500);
  static const paymentProcessingCurve = Curves.linear;

  /// Gold tick draws itself inside circular seal
  static const paymentSuccess = Duration(milliseconds: 700);
  static const paymentSuccessCurve = Curves.easeInOutQuart;

  /// Jewellery box closes, wraps, shows order ID
  static const orderPlaced = Duration(milliseconds: 1200);
  static const orderPlacedCurve = Curves.easeInOutCubic;

  /// Soft shake for payment failed
  static const paymentFailed = Duration(milliseconds: 400);
  static const paymentFailedCurve = Curves.elasticIn;

  // ── Gold Scheme & Goal animations ──────────────────────────────────────────

  /// Gold coin drops into vault
  static const schemeJoined = Duration(milliseconds: 600);
  static const schemeJoinedCurve = Curves.easeInQuart;

  /// Circular gold progress ring fills
  static const goalProgressFill = Duration(milliseconds: 800);
  static const goalProgressCurve = Curves.easeInOutSine;

  /// Milestone marker glows briefly
  static const milestoneGlow = Duration(milliseconds: 400);
  static const milestoneGlowCurve = Curves.easeOut;

  /// Vault opens to reveal accumulated gold
  static const schemeMature = Duration(milliseconds: 1000);
  static const schemeMatureCurve = Curves.easeInOutQuart;

  /// Grams count upward with shimmer
  static const gramsCredit = Duration(milliseconds: 600);
  static const gramsCreditCurve = Curves.easeOut;

  // ── Dream Vault & Wishlist animations ──────────────────────────────────────

  /// Heart fills with molten gold effect
  static const wishlistAdd = Duration(milliseconds: 400);
  static const wishlistAddCurve = Curves.easeInOutCubic;

  /// Product shrinks into glowing vault card
  static const vaultAdd = Duration(milliseconds: 500);
  static const vaultAddCurve = Curves.easeInCubic;

  // ── KYC & Onboarding animations ────────────────────────────────────────────

  /// Digits merge into verification tick
  static const otpVerified = Duration(milliseconds: 500);
  static const otpVerifiedCurve = Curves.easeInOutCubic;

  /// Profile card stamped "Under Review"
  static const kycSubmitted = Duration(milliseconds: 600);
  static const kycSubmittedCurve = Curves.easeInOutQuart;

  /// Identity card receives gold verified seal
  static const kycApproved = Duration(milliseconds: 700);
  static const kycApprovedCurve = Curves.easeInOutQuart;

  // ── Gold Rate animations ───────────────────────────────────────────────────

  /// Digits roll vertically like premium ticker
  static const rateRoll = Duration(milliseconds: 300);
  static const rateRollCurve = Curves.easeOut;

  /// Gold bell rings once
  static const rateAlert = Duration(milliseconds: 400);
  static const rateAlertCurve = Curves.elasticOut;

  // ── Aura animations ────────────────────────────────────────────────────────

  /// Elegant flowing line (not bouncing dots)
  static const auraThinking = Duration(milliseconds: 1200);
  static const auraThinkingCurve = Curves.easeInOutSine;

  /// Product cards emerge from soft spotlight
  static const auraRecommendation = Duration(milliseconds: 600);
  static const auraRecommendationCurve = Curves.easeOut;

  // ── Microinteractions ──────────────────────────────────────────────────────

  /// Gold border drawing around card
  static const borderTrace = Duration(milliseconds: 400);
  static const borderTraceCurve = Curves.easeInOutCubic;

  /// Success tick drawn (not instant)
  static const tickDraw = Duration(milliseconds: 500);
  static const tickDrawCurve = Curves.easeInOutQuart;

  /// Skeleton shimmer shaped like jewellery card
  static const skeletonShimmer = Duration(milliseconds: 1500);
  static const skeletonShimmerCurve = Curves.linear;

  /// Thin gold underline moves under active tab
  static const tabUnderline = Duration(milliseconds: 280);
  static const tabUnderlineCurve = Curves.easeInOutCubic;
}
