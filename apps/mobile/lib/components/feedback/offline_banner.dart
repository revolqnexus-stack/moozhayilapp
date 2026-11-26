import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/motion.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/services/connectivity_service.dart';

/// Global offline indicator banner.
/// Source: 01-product-spec.md § GLOBAL STATES — Network Offline Banner
/// Source: 03-component-library.md § OfflineBanner
///
/// Position: top of content area, below [AppTopBar].
/// Background: [AppColors.blushClay], height 36px.
/// Dismissible: yes.
/// Auto-hides when connectivity is restored.
///
/// Rule 13 (09-cursor-rules.md): Reads from [isOfflineProvider] only.
/// Individual screens must NOT implement their own offline state.
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _dismissed = false;
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.bannerSlide,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: AppMotion.standardInOut),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offline = ref.watch(isOfflineProvider);

    // When connectivity is restored, reset the dismissed flag so the banner
    // can reappear on the next disconnect.
    ref.listen(isOfflineProvider, (previous, next) {
      if (next) {
        _dismissed = false;
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    if (!offline || _dismissed) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        height: 36,
        color: AppColors.blushClay,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "You're offline. Some features may not load.",
                style: AppTypography.uiLabel.copyWith(
                  color: AppColors.obsidian,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _dismissed = true),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.obsidian,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
