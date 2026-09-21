import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../components/buttons/primary_button.dart';
import '../../../components/editorial/editorial_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/sample_imagery.dart';

class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slides = <({String key, String title, String body})>[
    (
      key: 'onboard-1',
      title: 'Own gold,\nbeautifully',
      body:
          'Plan milestones and grow your balance with calm, transparent pricing.',
    ),
    (
      key: 'onboard-2',
      title: 'Curated for\nyour moments',
      body:
          'Discover editorial collections crafted for weddings, festivals, and everyday grace.',
    ),
    (
      key: 'onboard-3',
      title: 'A maison\nyou can trust',
      body:
          'KYC-backed purchases, daily gold rates, and pieces made to last generations.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() => context.go(AppRoutes.auth);

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingLG,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: AppTypography.uiLabel.copyWith(
                        color: AppColors.maroonMuted,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_slides.length, (index) {
                      final active = index == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(left: 6),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.maroon
                              : AppColors.smokeLine,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final item = _slides[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      EditorialImage(
                        url: SampleImagery.editorial(item.key, width: 1400),
                        fit: BoxFit.cover,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.maroonSoft.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: AppColors.warmIvory,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingLG,
                AppSpacing.lg,
                AppSpacing.screenPaddingLG,
                AppSpacing.screenPaddingLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide.title,
                    style: AppTypography.displayLG.copyWith(
                      color: AppColors.maroon,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    slide.body,
                    style: AppTypography.uiBodyLG.copyWith(
                      color: AppColors.maroonMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: _page == _slides.length - 1
                        ? 'Get started'
                        : 'Continue',
                    isFullWidth: true,
                    onTap: () {
                      if (_page < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                        );
                      } else {
                        _finish();
                      }
                    },
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
