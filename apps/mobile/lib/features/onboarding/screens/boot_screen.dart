import 'dart:async';

import 'package:flutter/material.dart';

import '../../../components/brand/brand_monogram.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/services/api_warmup.dart';

/// Lightweight boot screen shown while the auth session is being restored.
///
/// This is the app's [initialLocation]. The router holds here until
/// [AuthController] resolves, then redirects to Home (signed in) or the login
/// flow (signed out). Keeping this as the first frame prevents the Home tab
/// shell from briefly painting before the auth state is known.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(warmProductionApi());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMonogram.hero(height: 96),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.gold.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
