import 'package:flutter/material.dart';

import '../../components/buttons/primary_button.dart';
import '../constants/colors.dart';
import '../constants/motion.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import '../utils/app_haptics.dart';
import '../utils/motion_preferences.dart';

/// Calm luxury success experience — ring, check, copy, optional CTAs.
///
/// Sequence (~700 ms draw + fade-up copy):
///   1. Gold ring expands and draws in.
///   2. Checkmark (or seal letter) fades in.
///   3. Title, optional detail, subtitle fade up.
///   4. Optional primary/secondary actions — or auto [onDone] after hold.
class LuxurySuccessOverlay extends StatefulWidget {
  const LuxurySuccessOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDone,
    this.detailLine,
    this.sealLetter,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.majorSuccess = false,
    this.autoDismissHold = const Duration(milliseconds: 2200),
  });

  final String title;
  final String subtitle;
  final VoidCallback onDone;
  final String? detailLine;
  final String? sealLetter;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool majorSuccess;
  final Duration autoDismissHold;

  bool get _hasActions => primaryActionLabel != null && onPrimaryAction != null;

  @override
  State<LuxurySuccessOverlay> createState() => _LuxurySuccessOverlayState();
}

class _LuxurySuccessOverlayState extends State<LuxurySuccessOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _checkCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _actionsCtrl;

  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _actionsOpacity;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _actionsCtrl = AnimationController(vsync: this, duration: AppMotion.normal);

    final ringCurved = CurvedAnimation(
      parent: _ringCtrl,
      curve: Curves.easeOutCubic,
    );

    _ringScale = Tween<double>(begin: 0.28, end: 1.0).animate(ringCurved);
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );
    _checkOpacity = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeIn);
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _actionsOpacity = CurvedAnimation(
      parent: _actionsCtrl,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _runSequence());
  }

  Future<void> _runSequence() async {
    if (!mounted) return;

    if (!premiumMotionEnabled(context)) {
      _ringCtrl.value = 1.0;
      _checkCtrl.value = 1.0;
      _textCtrl.value = 1.0;
      if (widget._hasActions) {
        _actionsCtrl.value = 1.0;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      widget.onDone();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (widget.majorSuccess) {
      AppHaptics.medium();
    } else {
      AppHaptics.light();
    }

    await _ringCtrl.forward();
    if (!mounted) return;

    await _checkCtrl.forward();
    if (!mounted) return;

    await _textCtrl.forward();
    if (!mounted) return;

    if (widget._hasActions) {
      await _actionsCtrl.forward();
      return;
    }

    await Future<void>.delayed(widget.autoDismissHold);
    if (!mounted) return;

    widget.onDone();
  }

  void _handlePrimary() {
    widget.onPrimaryAction?.call();
    widget.onDone();
  }

  void _handleSecondary() {
    widget.onSecondaryAction?.call();
    widget.onDone();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _checkCtrl.dispose();
    _textCtrl.dispose();
    _actionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ringCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _ringOpacity.value,
                    child: Transform.scale(
                      scale: _ringScale.value,
                      child: SizedBox(
                        width: 108,
                        height: 108,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 108,
                              height: 108,
                              child: CircularProgressIndicator(
                                value: _ringCtrl.value,
                                strokeWidth: 1.0,
                                color: AppColors.antiqueGold,
                                backgroundColor: AppColors.antiqueGold
                                    .withValues(alpha: 0.12),
                              ),
                            ),
                            FadeTransition(
                              opacity: _checkOpacity,
                              child: widget.sealLetter != null
                                  ? Text(
                                      widget.sealLetter!,
                                      style: AppTypography.headingLG.copyWith(
                                        color: AppColors.antiqueGold,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check,
                                      color: AppColors.antiqueGold,
                                      size: 36,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.headingMD.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.detailLine != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.detailLine!,
                            style: AppTypography.uiBodySM.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.subtitle,
                          style: AppTypography.auraVoice.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget._hasActions) ...[
                  const SizedBox(height: AppSpacing.xl),
                  FadeTransition(
                    opacity: _actionsOpacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          label: widget.primaryActionLabel!,
                          isFullWidth: true,
                          onTap: _handlePrimary,
                        ),
                        if (widget.secondaryActionLabel != null &&
                            widget.onSecondaryAction != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: _handleSecondary,
                            child: Text(
                              widget.secondaryActionLabel!,
                              style: AppTypography.uiBodySM.copyWith(
                                color: AppColors.brandBurgundy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
