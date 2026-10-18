import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/animated_badge.dart';
import '../../core/animations/bag_animation_targets.dart';
import '../../core/animations/premium_pressable.dart';
import '../../core/utils/app_haptics.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/iconography.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/routing/app_routes.dart';
import '../brand/brand_lockup.dart';
import '../icons/app_icon.dart';
import '../icons/app_icons.dart';
import 'heart_icon.dart';

/// The global top app bar for all main screens.
/// Source: 02-design-system.md § Navigation System — Top App Bar
/// Source: 03-component-library.md § TopAppBar
///
/// Variants:
///   [AppTopBar.main]    — hamburger + search + wordmark + Dream Vault + bag.
///   [AppTopBar.detail]  — back arrow + title + optional actions.
///   [AppTopBar.minimal] — back arrow only, no title.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar._({
    required this.variant,
    this.title,
    this.onMenuPressed,
    this.cartCount = 0,
    this.vaultHasSaved = false,
    this.actions = const [],
  });

  /// Main shell variant: hamburger + search + wordmark + Dream Vault + bag.
  factory AppTopBar.main({
    VoidCallback? onMenuPressed,
    int cartCount = 0,
    bool vaultHasSaved = false,
  }) {
    return AppTopBar._(
      variant: _AppTopBarVariant.main,
      onMenuPressed: onMenuPressed,
      cartCount: cartCount,
      vaultHasSaved: vaultHasSaved,
    );
  }

  /// Detail variant: back arrow + title + optional action icons.
  factory AppTopBar.detail({
    required String title,
    List<Widget> actions = const [],
  }) {
    return AppTopBar._(
      variant: _AppTopBarVariant.detail,
      title: title,
      actions: actions,
    );
  }

  /// Minimal variant: back + bag (product detail — enables fly-to-bag motion).
  factory AppTopBar.minimal({int cartCount = 0}) {
    return AppTopBar._(
      variant: _AppTopBarVariant.minimal,
      cartCount: cartCount,
    );
  }

  // ignore: library_private_types_in_public_api
  final _AppTopBarVariant variant;
  final String? title;
  final VoidCallback? onMenuPressed;
  final int cartCount;
  final bool vaultHasSaved;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.topBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.12),
            width: 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        height: AppSpacing.topBarHeight,
        child: switch (variant) {
          _AppTopBarVariant.main => _buildMain(context),
          _AppTopBarVariant.detail => _buildDetail(context),
          _AppTopBarVariant.minimal => _buildMinimal(context),
        },
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          _IconButton(
            icon: AppIcons.menu,
            onPressed: onMenuPressed,
            semanticLabel: 'Open navigation menu',
            utility: true,
          ),
          _IconButton(
            icon: AppIcons.search,
            onPressed: () => context.push('${AppRoutes.shop}/search'),
            semanticLabel: 'Search',
            utility: true,
          ),
          const Expanded(child: Center(child: BrandLockup())),
          _DreamVaultIconButton(
            hasSaved: vaultHasSaved,
            onPressed: () => context.push(AppRoutes.dreamVault),
          ),
          _CartIconButton(
            count: cartCount,
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          _IconButton(
            icon: AppIcons.back,
            onPressed: () {
              if (context.canPop()) context.pop();
            },
            semanticLabel: 'Go back',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                title ?? '',
                style: AppTypography.uiBodyMD.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.obsidian,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildMinimal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          _IconButton(
            icon: AppIcons.back,
            onPressed: () {
              if (context.canPop()) context.pop();
            },
            semanticLabel: 'Go back',
          ),
          const Spacer(),
          _CartIconButton(
            key: BagAnimationTargets.cartIconKey,
            count: cartCount,
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────

enum _AppTopBarVariant { main, detail, minimal }

/// Minimum 40×40 tap target icon button per accessibility standards.
class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.utility = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool utility;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      onTap: onPressed,
      scaleEnd: 0.92,
      semanticLabel: semanticLabel,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppIcon(
              icon,
              size: utility
                  ? AppIconography.sizeNavUtility
                  : AppIconography.sizeSm,
              color: utility
                  ? AppIconography.navUtility
                  : AppIconography.subtle,
            ),
          ],
        ),
      ),
    );
  }
}

class _DreamVaultIconButton extends StatelessWidget {
  const _DreamVaultIconButton({
    required this.hasSaved,
    required this.onPressed,
  });

  final bool hasSaved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasSaved ? 'Dream Vault, saved pieces' : 'Dream Vault',
      child: PremiumPressable(
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const HeartIcon(
                color: AppIconography.subtle,
                size: AppIconography.sizeSm,
                strokeWidth: 1.4,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedPulseDot(visible: hasSaved),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: count > 0 ? 'Bag, $count items' : 'Bag',
      child: PremiumPressable(
        onTap: () {
          AppHaptics.light();
          onPressed();
        },
        scaleEnd: 0.88,
        enableHaptic: true,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const AppIcon(
                AppIcons.bag,
                size: AppIconography.sizeSm,
                color: AppIconography.subtle,
              ),
              if (count > 0)
                Positioned(
                  top: 6,
                  right: 4,
                  child: AnimatedBadge(count: count),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
