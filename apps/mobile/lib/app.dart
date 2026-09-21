import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/colors.dart';
import 'core/routing/app_router.dart';
import 'core/widgets/server_clock_lifecycle.dart';
import 'features/auth/providers/auth_provider.dart';

/// Root widget of the Moozhayil application.
class MoozhayilApp extends ConsumerWidget {
  const MoozhayilApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final authState = ref.watch(authControllerProvider).value;

    return MaterialApp.router(
      title: 'Moozhayil',
      debugShowCheckedModeBanner: false,
      routerConfig: createAppRouter(authState: authState),
      theme: _buildTheme(),
      builder: (context, child) {
        return ServerClockLifecycle(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme(const TextTheme());

    const fadeTransitions = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _FadePageTransitionsBuilder(),
        TargetPlatform.iOS: _FadePageTransitionsBuilder(),
        TargetPlatform.macOS: _FadePageTransitionsBuilder(),
        TargetPlatform.windows: _FadePageTransitionsBuilder(),
        TargetPlatform.linux: _FadePageTransitionsBuilder(),
        TargetPlatform.fuchsia: _FadePageTransitionsBuilder(),
      },
    );

    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.paper,
      pageTransitionsTheme: fadeTransitions,
      colorScheme: const ColorScheme.light(
        primary: AppColors.textPrimary,
        onPrimary: AppColors.bgWhite,
        secondary: AppColors.gold,
        onSecondary: AppColors.ink,
        surface: AppColors.bgWhite,
        onSurface: AppColors.textPrimary,
        error: AppColors.blushClay,
        onError: AppColors.bgWhite,
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        filled: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.textPrimary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.paper,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.bgWhite,
        scrimColor: Color(0x6617120F),
        elevation: 16,
      ),
    );
  }
}

/// Refined fade + subtle slide for route transitions.
class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

