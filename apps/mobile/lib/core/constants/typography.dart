import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Moozhayil typography system.
///
/// Two typefaces only — as in any maison worth its name:
///
/// CORMORANT GARAMOND — the voice of the house.
///   Used for every heading, product name, editorial line, price headline.
///   Never bold. Weight 300 (light) for display, 400 (regular) for headings.
///   Generous tracking — at least 0.04em. Italic is used for emotional lines.
///
/// INTER — the precision of the atelier.
///   Used for all functional UI: labels, body copy, metadata, buttons, prices.
///   Never above weight 500. Uppercase micro labels tracked at 0.20em+.
///   Base body at 13–14px. Runs slightly small with generous line height.
///
/// The system is intentionally conservative. A jewellery maison does not
/// shout. It whispers — with perfect proportion and unhurried spacing.

abstract final class AppTypography {
  // ── Cormorant Garamond helpers ────────────────────────────────────────────

  static TextStyle _cormorant({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w300,
    FontStyle fontStyle = FontStyle.normal,
    double height = 1.1,
    double? letterSpacing,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing ?? (fontSize * 0.04),
      color: color,
      decoration: TextDecoration.none,
    );
  }

  static TextStyle _inter({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.55,
    double letterSpacing = 0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: TextDecoration.none,
    );
  }

  // ── Display — hero banners, editorial splashes ────────────────────────────

  /// Cinematic opener — hero banner primary line.
  static final TextStyle displayXL = _cormorant(
    fontSize: 54,
    height: 0.94,
    letterSpacing: 54 * 0.02,
  );

  /// Editorial section header — large serif.
  static final TextStyle displayLG = _cormorant(
    fontSize: 40,
    height: 1.0,
    letterSpacing: 40 * 0.03,
  );

  // ── Headings — screen titles, product names, section heads ───────────────

  static final TextStyle headingXL = _cormorant(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.06,
    letterSpacing: 32 * 0.025,
  );

  static final TextStyle headingLG = _cormorant(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.1,
    letterSpacing: 28 * 0.03,
  );

  static final TextStyle headingMD = _cormorant(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: 22 * 0.035,
  );

  static final TextStyle headingSM = _cormorant(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 18 * 0.04,
  );

  /// Product name on cards — compact, elegant.
  static final TextStyle productName = _cormorant(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 15 * 0.03,
  );

  /// Header lockup wordmark.
  static final TextStyle brandWordmark = _cormorant(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 17 * 0.08,
  );

  /// Screen serif title — editorial hero headlines.
  static final TextStyle screenTitle = _cormorant(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    height: 1.05,
    letterSpacing: 32 * 0.025,
  );

  /// Italic line — used for the second line of two-line heroes.
  static TextStyle displayItalic(double fontSize, {Color? color}) {
    return _cormorant(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      height: 1.02,
      letterSpacing: fontSize * 0.02,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// Aura AI voice — emotional italic copy.
  static final TextStyle auraVoice = _cormorant(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.55,
    letterSpacing: 17 * 0.02,
    color: AppColors.textSecondary,
  );

  // ── Drawer navigation ─────────────────────────────────────────────────────

  static TextStyle drawerNavPrimary({
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return _inter(
      fontSize: 17,
      fontWeight: fontWeight,
      height: 1.35,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle drawerNavSecondary({
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return _inter(
      fontSize: 14,
      fontWeight: fontWeight,
      height: 1.4,
      color: color ?? AppColors.textSecondary,
    );
  }

  static TextStyle drawerNav({Color? color, double fontSize = 17}) {
    return _inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle drawerSecondary({Color? color}) {
    return drawerNavSecondary(color: color);
  }

  // ── UI body text ──────────────────────────────────────────────────────────

  static final TextStyle uiBodyLG = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.65,
    color: AppColors.textSecondary,
  );

  static final TextStyle uiBodyMD = _inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static final TextStyle uiBodySM = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  // ── Labels and micro text ─────────────────────────────────────────────────

  /// Uppercase metadata label — spaced out for legibility.
  static final TextStyle uiLabel = _inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 10 * 0.20,
    color: AppColors.textMuted,
  );

  static final TextStyle uiCaption = _inter(
    fontSize: 11,
    fontWeight: FontWeight.w300,
    height: 1.45,
    color: AppColors.textMuted,
  );

  /// Eyebrow / badge micro — tracked tight uppercase.
  static final TextStyle uiMicro = _inter(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 9 * 0.22,
    color: AppColors.textMuted,
  );

  // ── Button labels ─────────────────────────────────────────────────────────

  /// Primary CTA label — tracked uppercase, deliberately restrained.
  static final TextStyle buttonLabel = _inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 11 * 0.18,
    color: AppColors.cream,
  );

  static final TextStyle buttonLabelSM = _inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 10 * 0.18,
    color: AppColors.cream,
  );

  // ── Price display ─────────────────────────────────────────────────────────

  /// Large price — product detail, checkout total.
  static final TextStyle priceLG = _inter(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Medium price — product cards.
  static final TextStyle priceMD = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Small price — secondary / per-gram rates.
  static final TextStyle priceSM = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 1.2,
    color: AppColors.textMuted,
  );

  /// Tabular figures for aligned rupee amounts in lists and checkout.
  static final TextStyle priceTabular = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textPrimary,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
