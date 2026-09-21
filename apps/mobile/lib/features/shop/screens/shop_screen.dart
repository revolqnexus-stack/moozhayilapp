import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/section_reveal.dart';
import '../../../core/constants/colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/sample_catalog.dart';
import '../../my_gold/providers/gold_balance_provider.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/time/server_clock_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/shop_catalog_section.dart';
import '../widgets/shop_collections_rail.dart';
import '../widgets/shop_masthead.dart';
import '../widgets/shop_occasions_grid.dart';
import '../widgets/shop_utility_strip.dart';

/// Shop tab — catalogue-first browse. Distinct from Home (no shared carousels).
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  static const _bottomNavHeight = 56.0;
  static const _scrollBottomInset = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = editorialList(
      ref.watch(featuredProductsProvider),
      SampleCatalog.products,
    );
    final collections = editorialList(
      ref.watch(featuredCollectionsProvider),
      SampleCatalog.collections,
    );
    final occasions = editorialList(
      ref.watch(occasionsProvider),
      SampleCatalog.occasions,
    );
    final goldRate = ref.watch(goldBalanceProvider);
    final clock = ref.watch(serverClockProvider);
    final isOffline = ref.watch(isOfflineProvider);

    final ratePaise = goldRate.maybeWhen(
      data: (b) => b.rateUsed.ratePaise,
      orElse: () => null,
    );
    final rateDisplay = goldRate.maybeWhen(
      data: (b) => b.rateUsed.rateDisplay,
      orElse: () => null,
    );
    final rateUpdatedAt = goldRate.maybeWhen(
      data: (b) => b.rateUsed.updatedAt,
      orElse: () => null,
    );
    final serverIsStale = goldRate.maybeWhen(
      data: (b) => b.rateUsed.isStale,
      orElse: () => null,
    );

    final bottomInset =
        MediaQuery.paddingOf(context).bottom +
        _bottomNavHeight +
        _scrollBottomInset;

    return ColoredBox(
      color: AppColors.warmIvory,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionReveal(
              index: 0,
              child: ShopMasthead(
                onSearchTap: () => context.push(AppRoutes.shopSearch),
                clock: clock,
                ratePaise: ratePaise,
                rateDisplay: rateDisplay,
                rateUpdatedAtIso: rateUpdatedAt,
                serverIsStale: serverIsStale,
                isRateLoading: goldRate.isLoading,
                isRateRefreshing: goldRate.isLoading && goldRate.hasValue,
                isOffline: isOffline,
                onRefreshRate: () => ref.invalidate(goldBalanceProvider),
                pieceCount: products.length,
              ),
            ),

            SectionReveal(
              index: 1,
              child: ShopCatalogSection(products: products),
            ),

            SectionReveal(
              index: 2,
              child: ShopOccasionsGrid(occasions: occasions),
            ),

            SectionReveal(
              index: 3,
              child: ShopCollectionsRail(collections: collections),
            ),

            const SectionReveal(index: 4, child: ShopUtilityStrip()),
          ],
        ),
      ),
    );
  }
}
