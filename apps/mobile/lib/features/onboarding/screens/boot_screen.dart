import 'dart:async';

import 'package:flutter/material.dart';

import '../../../components/brand/brand_monogram.dart';
import '../../../core/animations/gold_pulse.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/motion.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/services/api_warmup.dart';
import '../../../core/utils/motion_preferences.dart';

/// Lightweight boot screen shown while the auth session is being restored.
///
/// This is the app's [initialLocation]. The router holds here until
/// [AuthController] resolves, then redirects to Home (signed in) or the login
/// flow (signed out). Keeping this as the first frame prevents the Home tab
/// shell from briefly painting before the auth state is known.
///
/// Motion: the monogram fades in while settling from 0.94 → 1.0 scale
/// ([AppMotion.cinematic]); a gold pulse then appears below it while the
/// session restores. Both are skipped when reduced motion is on.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();
    unawaited(warmProductionApi());

    _reveal = AnimationController(vsync: this, duration: AppMotion.cinematic);
    _logoOpacity = CurvedAnimation(
      parent: _reveal,
      curve: const Interval(0.0, 0.7, curve: AppMotion.standard),
    );
    _logoScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _reveal,
        curve: const Interval(0.0, 1.0, curve: AppMotion.emphasized),
      ),
    );
    _loaderOpacity = CurvedAnimation(
      parent: _reveal,
      curve: const Interval(0.6, 1.0, curve: AppMotion.standard),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reveal.isDismissed) {
      if (premiumMotionEnabled(context)) {
        _reveal.forward();
      } else {
        _reveal.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: const BrandMonogram.hero(height: 96),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FadeTransition(
              opacity: _loaderOpacity,
              child: const SizedBox(
                height: 22,
                child: Center(child: GoldPulse(size: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
