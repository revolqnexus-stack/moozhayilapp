import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/legal_urls.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import 'monogram_pattern.dart';

/// Deep-burgundy brand footer — oversized wordmark over a monogram texture,
/// followed by contact, help, and about columns.
class EditorialFooter extends StatelessWidget {
  const EditorialFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.burgundyDark)),
        const MonogramPattern(opacity: 0.05),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPaddingLG,
            AppSpacing.x3l,
            AppSpacing.screenPaddingLG,
            AppSpacing.x3l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moozhayil',
                style: AppTypography.displayLG.copyWith(
                  fontSize: 44,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'GOLD & DIAMONDS · SINCE 1969',
                style: AppTypography.uiMicro.copyWith(
                  color: AppColors.goldLight,
                  letterSpacing: 9 * 0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _FooterColumn(
                title: 'Contact',
                lines: [
                  'Start chat — Mon–Fri, 10am–7pm',
                  '+91 484 000 0000',
                  'hello@moozhayil.com — reply within 24hrs',
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FooterColumn(
                title: 'Help',
                lines: [
                  'Shop online',
                  'Payment & gold rates',
                  'Shipping & returns',
                  'Gift cards',
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FooterColumn(
                title: 'About',
                lines: ['About us', 'Popular questions', 'Store locator'],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Row(
                children: [
                  Icon(Icons.camera_alt_outlined, color: AppColors.goldLight),
                  SizedBox(width: AppSpacing.lg),
                  Icon(Icons.facebook_outlined, color: AppColors.goldLight),
                  SizedBox(width: AppSpacing.lg),
                  Icon(Icons.alternate_email, color: AppColors.goldLight),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  _LegalLink(label: 'Terms', url: LegalUrls.terms),
                  Text(
                    '·',
                    style: AppTypography.uiCaption.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.6),
                    ),
                  ),
                  _LegalLink(label: 'Privacy', url: LegalUrls.privacy),
                  Text(
                    '·',
                    style: AppTypography.uiCaption.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.6),
                    ),
                  ),
                  _LegalLink(
                    label: 'Accessibility',
                    url: LegalUrls.accessibility,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Text(
        label,
        style: AppTypography.uiCaption.copyWith(
          color: AppColors.cream.withValues(alpha: 0.82),
          decoration: TextDecoration.underline,
          decorationColor: AppColors.cream.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.buttonLabelSM.copyWith(
            color: AppColors.goldLight,
            letterSpacing: 9 * 0.24,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Text(
              line,
              style: AppTypography.uiCaption.copyWith(
                color: AppColors.cream.withValues(alpha: 0.82),
              ),
            ),
          ),
      ],
    );
  }
}
