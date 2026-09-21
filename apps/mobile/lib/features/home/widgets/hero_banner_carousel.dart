import 'dart:async';

import 'package:flutter/material.dart';

import '../../../components/editorial/editorial_image.dart';
import '../../../core/animations/fade_slide_in.dart';
import '../../../core/animations/premium_pressable.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/motion.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/product.dart';
import '../../../core/utils/cms_navigation.dart';
import '../../../core/utils/sample_imagery.dart';
import 'carousel_dots.dart';

/// Cinematic hero banner carousel with swipe, dots, and optional auto-play.
class HeroBannerCarousel extends StatefulWidget {
  const HeroBannerCarousel({super.key, required this.banners, this.height});

  final List<CmsBanner> banners;
  final double? height;

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  late final PageController _controller;
  Timer? _autoPlay;
  int _index = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlay?.cancel();
    if (widget.banners.length <= 1) return;

    _autoPlay = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _dragging) return;
      final next = (_index + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: AppMotion.heroPage,
        curve: AppMotion.standard,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    if (banners.isEmpty) return const SizedBox.shrink();

    final height = widget.height ?? MediaQuery.sizeOf(context).height * 0.48;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                setState(() => _dragging = true);
              } else if (notification is ScrollEndNotification) {
                setState(() => _dragging = false);
              }
              return false;
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return PageView.builder(
                  controller: _controller,
                  itemCount: banners.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    final page = _controller.hasClients
                        ? (_controller.page ??
                              _controller.initialPage.toDouble())
                        : _controller.initialPage.toDouble();
                    final delta = (page - index).abs();
                    final focus = (1 - delta.clamp(0.0, 1.0));
                    final imageScale =
                        1.0 + (focus * (AppMotion.heroImageScaleMax - 1.0));

                    return _HeroSlide(
                      banner: banner,
                      imageScale: imageScale,
                      isActive: index == _index,
                      onTap: () => navigateCmsRoute(context, banner.ctaRoute),
                      onCta: banner.ctaLabel != null
                          ? () => navigateCmsRoute(context, banner.ctaRoute)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CarouselDots(count: banners.length, index: _index),
        const SizedBox(height: 36),
      ],
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({
    required this.banner,
    required this.imageScale,
    required this.isActive,
    required this.onTap,
    this.onCta,
  });

  final CmsBanner banner;
  final double imageScale;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final parts = banner.title.split('\n');
    final lineOne = parts.first;
    final lineTwo = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    return PremiumPressable(
      onTap: onTap,
      scaleEnd: 0.995,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.homeScreenPadding,
        ),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: imageScale,
                alignment: Alignment.center,
                child: EditorialImage(
                  url: SampleImagery.editorialOr(
                    banner.imageUrl,
                    banner.id,
                    width: 1400,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.brandBurgundy.withValues(alpha: 0.42),
                      AppColors.brandBurgundy.withValues(alpha: 0.88),
                    ],
                    stops: const [0.35, 0.70, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg + AppSpacing.sm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isActive)
                      FadeSlideIn(
                        duration: AppMotion.cinematic,
                        offsetY: 10,
                        child: Text(
                          'MOOZHAYIL',
                          style: AppTypography.uiMicro.copyWith(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.4,
                          ),
                        ),
                      )
                    else
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
                    if (isActive)
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        duration: AppMotion.cinematic,
                        offsetY: 12,
                        child: Text(
                          lineOne,
                          style: AppTypography.headingLG.copyWith(
                            color: AppColors.ivory,
                            fontSize: 38,
                            height: 1.05,
                            letterSpacing: 0.05,
                          ),
                        ),
                      )
                    else
                      Text(
                        lineOne,
                        style: AppTypography.headingLG.copyWith(
                          color: AppColors.ivory,
                          fontSize: 38,
                          height: 1.05,
                          letterSpacing: 0.05,
                        ),
                      ),
                    if (lineTwo != null)
                      isActive
                          ? FadeSlideIn(
                              delay: const Duration(milliseconds: 140),
                              duration: AppMotion.cinematic,
                              offsetY: 12,
                              child: Text(
                                lineTwo,
                                style: AppTypography.displayItalic(
                                  36,
                                  color: AppColors.ivory,
                                ),
                              ),
                            )
                          : Text(
                              lineTwo,
                              style: AppTypography.displayItalic(
                                36,
                                color: AppColors.ivory,
                              ),
                            ),
                    if (banner.ctaLabel != null && onCta != null)
                      isActive
                          ? FadeSlideIn(
                              delay: const Duration(milliseconds: 280),
                              duration: AppMotion.normal,
                              offsetY: 8,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.md,
                                ),
                                child: PremiumPressable(
                                  onTap: onCta,
                                  scaleEnd: AppMotion.pressScale,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xl,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.ivory,
                                          AppColors.ivory.withValues(
                                            alpha: 0.95,
                                          ),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(
                                          alpha: 0.45,
                                        ),
                                        width: 0.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.ink.withValues(
                                            alpha: 0.22,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                        BoxShadow(
                                          color: AppColors.gold.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      banner.ctaLabel!.toUpperCase(),
                                      style: AppTypography.buttonLabelSM
                                          .copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.brandBurgundy,
                                            letterSpacing: 2.4,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.md,
                              ),
                              child: Container(
                                height: 46,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.brandBurgundy,
                                  border: Border.all(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.45,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  banner.ctaLabel!.toUpperCase(),
                                  style: AppTypography.buttonLabelSM.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.cream,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                              ),
                            ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
