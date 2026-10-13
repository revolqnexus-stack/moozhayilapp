import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/section_reveal.dart';
import '../../../components/editorial/editorial_footer.dart';
import '../../../components/editorial/editorial_image.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../core/config/dev_preview.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/cms_navigation.dart';
import '../../../core/utils/sample_catalog.dart';
import '../../../core/utils/sample_banners.dart';
import '../../../core/utils/sample_imagery.dart';
import '../../shop/providers/products_provider.dart';
import '../../my_gold/providers/gold_balance_provider.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/time/server_clock_provider.dart';
import '../widgets/category_pop_carousel.dart';
import '../widgets/featured_jewellery_section.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/home_section_inset.dart';
import '../widgets/live_gold_rate_strip.dart';
import '../widgets/our_works_showcase_carousel.dart';
import '../widgets/schemes_banner_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _bottomNavHeight = 56.0;
  static const _scrollBottomInset = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProductsProvider);
    final products = editorialList(featuredAsync, SampleCatalog.products);
    final goldRate = ref.watch(goldBalanceProvider);
    final clock = ref.watch(serverClockProvider);
    final isOffline = ref.watch(isOfflineProvider);

    final isLoading = goldRate.isLoading;
    final isRefreshing = goldRate.isLoading && goldRate.hasValue;
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
    final purityLabel = goldRate.maybeWhen(
      data: (b) => _formatPurity(b.rateUsed.purity),
      orElse: () => '22KT',
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
              child: LiveGoldRateStrip(
                ratePaise: ratePaise,
                rateDisplay: rateDisplay,
                rateUpdatedAtIso: rateUpdatedAt,
                serverIsStale: serverIsStale,
                clock: clock,
                purityLabel: purityLabel,
                isLoading: isLoading,
                isRefreshing: isRefreshing,
                isOffline: isOffline,
                onRefreshRate: () {
                  ref.invalidate(goldBalanceProvider);
                },
              ),
            ),

            const SectionReveal(index: 1, child: _HomeHeroSection()),

            const SectionReveal(index: 2, child: CategoryPopCarousel()),

            const SectionReveal(index: 3, child: SchemesBannerCarousel()),

            SectionReveal(
              index: 4,
              child: !DevPreview.enabled && featuredAsync.hasError
                  ? _HomeSectionError(
                      onRetry: () => ref.invalidate(featuredProductsProvider),
                    )
                  : FeaturedJewellerySection(products: products),
            ),

            SectionReveal(
              index: 5,
              child: OurWorksShowcaseCarousel(
                items: ourWorksFromProducts(products),
              ),
            ),

            SectionReveal(
              index: 6,
              child: HomeSectionInset(
                top: 8,
                bottom: 48,
                child: _HomeAdvisorCard(
                  onTap: () => context.go(AppRoutes.aura),
                ),
              ),
            ),

            SectionReveal(
              index: 7,
              child: HomeSectionInset(
                top: 0,
                bottom: 16,
                child: _HomeShowroomCard(
                  onVisit: () => context.push(AppRoutes.storeLocator),
                ),
              ),
            ),

            const SectionReveal(index: 8, child: EditorialFooter()),
          ],
        ),
      ),
    );
  }

  static String _formatPurity(String purity) {
    final normalized = purity.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    if (normalized.contains('K')) return normalized.replaceAll(' ', '');
    if (normalized.length >= 2) return '${normalized}KT';
    return '22KT';
  }
}

class _HomeAdvisorCard extends StatelessWidget {
  const _HomeAdvisorCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brandBurgundy,
              AppColors.brandBurgundy.withValues(alpha: 0.92),
            ],
          ),
          border: Border(
            left: BorderSide(color: AppColors.gold, width: 3),
            top: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.28),
              width: 0.5,
            ),
            right: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.28),
              width: 0.5,
            ),
            bottom: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.28),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBurgundy.withValues(alpha: 0.24),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI ADVISOR',
                    style: AppTypography.uiMicro.copyWith(
                      color: AppColors.goldLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your jewellery concierge',
                    style: AppTypography.headingMD.copyWith(
                      color: AppColors.cream,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Plans, weddings, gifting, and gold.',
                    style: AppTypography.uiBodySM.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.78),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'ASK ADVISOR →',
                    style: AppTypography.buttonLabelSM.copyWith(
                      color: AppColors.goldLight,
                      fontSize: 11,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.auto_awesome_outlined,
              size: 26,
              color: AppColors.gold.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeShowroomCard extends StatelessWidget {
  const _HomeShowroomCard({required this.onVisit});

  final VoidCallback onVisit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onVisit,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: AppSpacing.x3l * 3,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            EditorialImage(
              url: SampleImagery.editorial('showroom-pala', width: 1200),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.brandBurgundy.withValues(alpha: 0.88),
                    AppColors.brandBurgundy.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'VISIT OUR SHOWROOM',
                    style: AppTypography.uiMicro.copyWith(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Experience Moozhayil in Pala',
                    style: AppTypography.headingSM.copyWith(
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'STORE LOCATOR →',
                    style: AppTypography.buttonLabelSM.copyWith(
                      color: AppColors.goldLight,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home hero that handles loading, error, and empty states explicitly instead
/// of collapsing to nothing when live banner data is unavailable.
class _HomeHeroSection extends ConsumerWidget {
  const _HomeHeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cmsBannersProvider('home_hero'));
    final height = MediaQuery.sizeOf(context).height * 0.48;

    // Debug/preview: always show believable sample slides.
    if (DevPreview.enabled) {
      final banners = (async.value?.isNotEmpty ?? false)
          ? async.value!
          : SampleBanners.forPlacement('home_hero');
      return HeroBannerCarousel(banners: banners);
    }

    return async.when(
      data: (banners) => banners.isEmpty
          ? _HeroFallback(height: height)
          : HeroBannerCarousel(banners: banners),
      loading: () => _HeroSkeleton(height: height),
      error: (_, _) => _HeroError(
        height: height,
        onRetry: () => ref.invalidate(cmsBannersProvider('home_hero')),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.homeScreenPadding,
      ),
      child: LoadingShimmer.full(height: height, borderRadius: 0),
    );
  }
}

class _HeroError extends StatelessWidget {
  const _HeroError({required this.height, required this.onRetry});

  final double height;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: ErrorState(
          headline: 'We couldn\u2019t load the latest highlights',
          body: 'Please check your connection and try again.',
          onRetry: onRetry,
        ),
      ),
    );
  }
}

/// Branded, network-free hero shown when the CMS returns no active slides, so
/// Home always has a hero rather than a blank gap.
class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.homeScreenPadding,
      ),
      child: GestureDetector(
        onTap: () => navigateCmsRoute(context, AppRoutes.shop),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brandBurgundy,
                AppColors.brandBurgundy.withValues(alpha: 0.86),
              ],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.35),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MOOZHAYIL',
                  style: AppTypography.uiMicro.copyWith(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elegance meets mastery',
                  style: AppTypography.headingLG.copyWith(
                    color: AppColors.ivory,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'EXPLORE THE COLLECTION →',
                  style: AppTypography.buttonLabelSM.copyWith(
                    color: AppColors.goldLight,
                    fontSize: 11,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact retry strip for a data-driven Home section that failed to load.
class _HomeSectionError extends StatelessWidget {
  const _HomeSectionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: ErrorState(
        headline: 'We couldn\u2019t load this section',
        body: 'Please check your connection and try again.',
        onRetry: onRetry,
      ),
    );
  }
}
