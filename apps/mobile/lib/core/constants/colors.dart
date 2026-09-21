import 'package:flutter/material.dart';

/// Moozhayil — Heritage jewellery palette.
/// Built on the palette of aged ivory, deep burgundy oxblood, and 22KT gold.
/// Every colour choice references the physical experience of the atelier:
/// — Paper: the white of freshly pressed velvet display cloth
/// — Ink: the depth of polished rosewood vitrines
/// — Gold: the warmth of hallmarked 22KT, not chrome yellow
/// — Burgundy: the lining of a Moozhayil jewellery box

abstract final class AppColors {
  // ── Core surfaces ─────────────────────────────────────────────────────────

  /// Warm white — the colour of pressed velvet display cloth.
  static const Color paper = Color(0xFFFEFCF9);

  /// Aged ivory — secondary surface, cards on white ground.
  static const Color pearl = Color(0xFFF8F5F0);

  /// Antique linen — tertiary surface, subtle panel warmth.
  static const Color ivory = Color(0xFFF4EDE3);

  /// Navigation drawer surface.
  static const Color drawerSurface = Color(0xFFFEFCF9);

  /// Pure white for product photography backgrounds.
  static const Color bgWhite = Color(0xFFFFFFFF);

  /// Deep rosewood — the colour of the atelier interior.
  /// Primary dark surface, hero overlays, footer.
  static const Color ink = Color(0xFF14100D);

  // ── Brand ─────────────────────────────────────────────────────────────────

  /// Oxblood burgundy — the lining of a Moozhayil box.
  static const Color brandBurgundy = Color(0xFF6B1020);

  /// Alias for primary CTAs.
  static const Color brandPrimary = brandBurgundy;

  /// Deeper burgundy — full-bleed editorial panels.
  static const Color burgundyDeep = Color(0xFF5C0D1A);

  /// Darkest — footer ground, pattern base.
  static const Color burgundyDark = Color(0xFF3A0910);

  /// Warm cream — type and elements over dark grounds only.
  static const Color cream = Color(0xFFF2E8DC);

  // ── Gold — the heart of everything ───────────────────────────────────────

  /// 22KT hallmark gold. Warm, rich, never chrome.
  static const Color gold = Color(0xFFC49A3C);

  /// Lighter gold for text on dark grounds.
  static const Color goldLight = Color(0xFFDDB96A);

  /// Deep gold for pressed states.
  static const Color goldDeep = Color(0xFFA07E2E);

  /// Gold at 15% opacity — the faintest trace of metal on a surface.
  static const Color goldTrace = Color(0x26C49A3C);

  // ── Text ──────────────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFF14100D);
  static const Color textSecondary = Color(0xFF635C54);
  static const Color textMuted = Color(0xFF9A9189);
  static const Color textOnDark = Color(0xFFF2E8DC);

  // ── Borders ───────────────────────────────────────────────────────────────

  /// Hairline — barely visible warmth against white.
  static const Color border = Color(0xFFEAE3D8);

  /// Gold border — for panels and cards that reference the metal.
  static const Color borderGold = Color(0xFFD4B87A);

  /// Strong — for active states, dividers.
  static const Color borderStrong = Color(0xFFD6CCBF);

  // ── Glass / overlay ───────────────────────────────────────────────────────

  static const Color glassSurface = Color(0xF4FEFCF9);
  static const Color glassBorder = Color(0xFFE5DDD2);
  static const Color shadowSoft = Color(0x1214100D);
  static const Color shadowMedium = Color(0x1F14100D);

  // ── Feedback ──────────────────────────────────────────────────────────────

  static const Color successFill = Color(0xFF1A6647);
  static const Color warningFill = Color(0xFF8C6A20);
  static const Color errorFill = Color(0xFF8C2020);

  static const Color disabledBg = Color(0xFFE8E2DA);
  static const Color disabledText = Color(0xFF6B645C);

  static const Color shimmerBase = Color(0xFFF4F0EB);
  static const Color shimmerHighlight = Color(0xFFE8E2D8);

  // ── Legacy aliases — keep existing code compiling ────────────────────────

  static const Color maroon = brandBurgundy;
  static const Color maroonDeep = ink;
  static const Color maroonSoft = pearl;
  static const Color maroonMuted = textSecondary;
  static const Color obsidian = textPrimary;
  static const Color deepMahogany = ink;
  static const Color slateMist = textMuted;
  static const Color warmIvory = paper;
  static const Color offWhite = paper;
  static const Color champagneVeil = pearl;
  static const Color pureWhite = bgWhite;
  static const Color smokeLine = border;
  static const Color antiqueGold = gold;
  static const Color antiqueGoldPressed = goldDeep;
  static const Color blushClay = Color(0xFFA07060);
  static const Color sageWhisper = Color(0xFF8A8070);
  static const Color vaultDusk = pearl;
  static const Color starlightGold = gold;
  static const Color moonveil = pearl;
  static const Color nebulaEdge = border;
}
