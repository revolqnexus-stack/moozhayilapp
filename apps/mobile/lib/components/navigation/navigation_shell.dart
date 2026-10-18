import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/providers/cart_badge_provider.dart';
import '../../features/vault/providers/vault_product_ids_display.dart';
import '../../features/shop/utils/shell_route_chrome.dart';
import '../../features/shop/widgets/shop_browse_app_bar.dart';
import '../../../core/utils/app_haptics.dart';
import '../feedback/offline_banner.dart';
import 'bottom_tab_bar.dart';
import 'navigation_drawer.dart';
import 'top_app_bar.dart';

/// Root shell widget for the persistent branch navigation.
///
/// Renders [AppTopBar] (main variant) + the side [AppNavigationDrawer] +
/// [OfflineBanner] + the current branch content + [AppBottomTabBar].
///
/// Rule 13 (09-cursor-rules.md): The [OfflineBanner] is rendered here
/// (below [AppTopBar]) and never inside individual screens.
///
/// The [GlobalKey<ScaffoldState>] is held in [State] — never created
/// inside [build] — so it is stable across rebuilds.
class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onSelectBranch(int branchIndex) {
    if (branchIndex != widget.navigationShell.currentIndex) {
      AppHaptics.selection();
    }
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultIds = ref.watch(displayVaultProductIdsProvider);
    final cartCount = ref.watch(cartBadgeCountProvider);
    final vaultHasSaved = vaultIds.isNotEmpty;
    final auth = ref.watch(authControllerProvider);
    final user = auth.value?.user;
    final userName = user?.name?.trim().isNotEmpty == true
        ? user!.name!.trim()
        : 'Guest';
    final memberSinceRaw = user?.memberSince;
    final memberSince = memberSinceRaw != null && memberSinceRaw.length >= 4
        ? int.tryParse(memberSinceRaw.substring(0, 4)) ?? DateTime.now().year
        : DateTime.now().year;

    final location = GoRouterState.of(context).uri.path;
    final shopBrowse = ShopBrowseRoute.tryParse(location);
    final hideBottomNav = shellHidesBottomNav(location);

    final PreferredSizeWidget appBar;
    if (!shellUsesSubRouteAppBar(location)) {
      appBar = AppTopBar.main(
        onMenuPressed: _openDrawer,
        cartCount: cartCount,
        vaultHasSaved: vaultHasSaved,
      );
    } else if (shellUsesMinimalAppBar(location)) {
      appBar = AppTopBar.minimal(cartCount: cartCount);
    } else if (shopBrowse != null &&
        shopBrowse.kind != ShopBrowseKind.product) {
      appBar = ShopBrowseAppBar(route: shopBrowse);
    } else {
      appBar = AppTopBar.detail(title: shellDetailTitle(location));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.warmIvory,
      extendBody: !hideBottomNav,
      drawerScrimColor: AppColors.ink.withValues(alpha: 0.68),
      appBar: appBar,
      drawer: AppNavigationDrawer(userName: userName, memberSince: memberSince),
      body: Column(
        children: [
          // Global offline indicator — shown below TopAppBar per spec.
          const OfflineBanner(),
          // Active branch content.
          Expanded(child: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: hideBottomNav
          ? null
          : AppBottomTabBar(
              currentBranchIndex: widget.navigationShell.currentIndex,
              onSelect: _onSelectBranch,
            ),
    );
  }
}
