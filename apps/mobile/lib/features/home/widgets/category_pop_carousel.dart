import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../components/editorial/editorial_image.dart';

import '../../../core/animations/premium_pressable.dart';

import '../../../core/constants/colors.dart';

import '../../../core/constants/shadows.dart';

import '../../../core/constants/spacing.dart';

import '../../../core/constants/typography.dart';

import '../../../core/routing/app_routes.dart';

import '../../../core/utils/catalog_imagery.dart';

import 'home_section_inset.dart';

/// Shop-by-category item for the center-pop carousel.

class HomeCategory {
  const HomeCategory({
    required this.name,

    required this.imageKey,

    this.subtitle,
  });

  final String name;

  final String imageKey;

  final String? subtitle;
}

const homeCategories = <HomeCategory>[
  HomeCategory(
    name: 'Pendant',
    imageKey: 'ginkgo',
    subtitle: 'Everyday & gifting',
  ),

  HomeCategory(
    name: 'Necklace',
    imageKey: 'celeste',
    subtitle: 'Temple, bridal & daily wear',
  ),

  HomeCategory(
    name: 'Bangle',
    imageKey: '1611107683227-e9060eccd846',
    subtitle: 'Classic gold bangles',
  ),

  HomeCategory(name: 'Ring', imageKey: 'band', subtitle: 'Bands & solitaires'),

  HomeCategory(
    name: 'Earrings',
    imageKey: 'luna',
    subtitle: 'Studs, hoops & jhumkas',
  ),

  HomeCategory(
    name: 'Bridal',
    imageKey: 'temple',
    subtitle: 'Wedding collections',
  ),

  HomeCategory(
    name: 'Diamond',
    imageKey: '1605100804763-247f67b3557e',
    subtitle: 'Certified stones',
  ),

  HomeCategory(
    name: 'Silver',
    imageKey: '1611591437281-460bfbe1220a',
    subtitle: 'Silver & fusion',
  ),
];

/// Category carousel with center-pop scale and opacity effect.

class CategoryPopCarousel extends StatefulWidget {
  const CategoryPopCarousel({super.key});

  @override
  State<CategoryPopCarousel> createState() => _CategoryPopCarouselState();
}

class _CategoryPopCarouselState extends State<CategoryPopCarousel> {
  static const _viewportFraction = 0.66;

  late final PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeSectionInset(
      top: 8,

      bottom: 48,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          HomeSectionHeader(
            title: 'Shop by Category',

            actionLabel: 'View all',

            onAction: () => context.go(AppRoutes.shop),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: AppSpacing.x3l * 2 + AppSpacing.lg,

            child: AnimatedBuilder(
              animation: _controller,

              builder: (context, _) {
                return PageView.builder(
                  controller: _controller,

                  itemCount: homeCategories.length,

                  itemBuilder: (context, index) {
                    final page = _controller.hasClients
                        ? (_controller.page ??
                              _controller.initialPage.toDouble())
                        : _controller.initialPage.toDouble();

                    final delta = (page - index).abs();

                    final focus = (1 - delta.clamp(0.0, 1.0));

                    final scale = 0.94 + (focus * 0.14);

                    final opacity = 0.78 + (focus * 0.22);

                    final lift = (1 - focus) * 5;

                    final titleOpacity = 0.72 + (focus * 0.28);

                    final category = homeCategories[index];

                    return Transform.translate(
                      offset: Offset(0, lift),

                      child: Transform.scale(
                        scale: scale,

                        child: Opacity(
                          opacity: opacity,

                          child: _CategoryCard(
                            category: category,

                            isFocused: focus > 0.85,

                            titleOpacity: titleOpacity,

                            onTap: () => context.push(AppRoutes.shopSearch),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,

    required this.isFocused,

    required this.titleOpacity,

    required this.onTap,
  });

  final HomeCategory category;

  final bool isFocused;

  final double titleOpacity;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),

        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),

          child: Stack(
            fit: StackFit.expand,

            children: [
              EditorialImage(
                url: CatalogImagery.resolveProduct(null, category.imageKey),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,

                    end: Alignment.bottomCenter,

                    colors: [
                      Colors.transparent,

                      AppColors.brandBurgundy.withValues(alpha: 0.58),
                      AppColors.brandBurgundy.withValues(alpha: 0.80),
                    ],

                    stops: const [0.45, 0.80, 1.0],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomLeft,

                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Opacity(
                        opacity: titleOpacity,

                        child: Text(
                          category.name,

                          style: AppTypography.uiBodyMD.copyWith(
                            color: AppColors.ivory,

                            fontSize: 17,

                            fontWeight: FontWeight.w500,

                            letterSpacing: 0.04,
                          ),
                        ),
                      ),

                      if (category.subtitle != null) ...[
                        const SizedBox(height: 2),

                        Opacity(
                          opacity: titleOpacity * 0.85,

                          child: Text(
                            category.subtitle!,

                            style: AppTypography.uiBodySM.copyWith(
                              color: AppColors.cream.withValues(alpha: 0.75),

                              fontSize: 11,
                            ),

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
