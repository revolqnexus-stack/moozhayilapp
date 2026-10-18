import 'package:flutter/material.dart';

/// Whether premium motion (scale, stagger, decorative sequences) should run.
///
/// Respects the platform reduced-motion / disable-animations setting.
bool premiumMotionEnabled(BuildContext context) {
  return !MediaQuery.disableAnimationsOf(context);
}

/// Duration multiplier — `0` when motion is reduced, otherwise `1`.
double motionDurationScale(BuildContext context) {
  return premiumMotionEnabled(context) ? 1.0 : 0.0;
}
