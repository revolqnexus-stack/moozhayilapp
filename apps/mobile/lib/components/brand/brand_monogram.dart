import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/typography.dart';

/// Moozhayil brand mark with two usage modes.
///
/// • [BrandMonogram] (default) — crisp flat SVG monogram for navigation /
///   app bars. Transparent, no shadow, no 3D bevel. Sharp at 22–28px.
/// • [BrandMonogram.hero] — the full 3D rendered emblem for splash,
///   onboarding, login, about, and premium brand moments. Shown large.
class BrandMonogram extends StatelessWidget {
  const BrandMonogram({super.key, this.height = 26}) : hero = false;

  /// Large 3D brand emblem for splash / onboarding / brand moments.
  const BrandMonogram.hero({super.key, this.height = 120}) : hero = true;

  final double height;
  final bool hero;

  static const _flatAsset = 'assets/images/moozhayil_monogram_flat.svg';
  static const _heroAsset = 'assets/images/moozhayil_logo.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Moozhayil Gold & Diamonds',
      child: hero ? _buildHero() : _buildFlat(),
    );
  }

  Widget _buildFlat() {
    return SvgPicture.asset(
      _flatAsset,
      height: height,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => _wordmark(),
    );
  }

  Widget _buildHero() {
    return Image.asset(
      _heroAsset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => _wordmark(fontSize: 28),
    );
  }

  Widget _wordmark({double fontSize = 17}) {
    return Text(
      'Moozhayil',
      style: AppTypography.brandWordmark.copyWith(fontSize: fontSize),
    );
  }
}
