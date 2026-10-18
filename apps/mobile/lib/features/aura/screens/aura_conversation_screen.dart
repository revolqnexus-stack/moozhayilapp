import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../components/inputs/text_input.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/animations/aura_thinking_animation.dart';
import '../../../core/animations/premium_pressable.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/contact_launcher.dart';
import '../../../core/utils/customer_error_copy.dart';
import '../providers/aura_provider.dart';
import '../widgets/aura_conversation_card.dart';

class AuraConversationScreen extends ConsumerStatefulWidget {
  const AuraConversationScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<AuraConversationScreen> createState() =>
      _AuraConversationScreenState();
}

class _AuraConversationScreenState
    extends ConsumerState<AuraConversationScreen> {
  final _controller = TextEditingController();
  bool _isSending = false;

  static const _quickPrompts = [
    'Help me choose a Scheme',
    'Wedding jewellery ideas',
    'What is today\u2019s gold rate?',
    'Visit the showroom',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    setState(() => _isSending = true);

    try {
      if (preset == 'Visit the showroom') {
        final launched = await ContactLauncher.callShowroom();
        if (!launched && mounted) {
          ContactLauncher.showLaunchError(context);
        }
        return;
      }
      await ref
          .read(auraConversationProvider(widget.sessionId).notifier)
          .sendMessage(text);
    } catch (error) {
      if (!mounted) return;
      showPremiumSnackBar(
        context,
        CustomerErrorCopy.message(error),
        haptic: false,
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(auraConversationProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'AI Advisor'),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (items) {
                if (items.isEmpty) {
                  return Column(
                    children: [
                      const Expanded(
                        child: EmptyState(
                          icon: Icons.chat_bubble_outline,
                          headline: 'Your advisor is ready',
                          body:
                              'Ask about Schemes, gold rates, gifting, or wedding jewellery.',
                        ),
                      ),
                      _QuickPromptBar(prompts: _quickPrompts, onPrompt: _send),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(
                          AppSpacing.homeScreenPadding,
                        ),
                        itemCount: items.length + (_isSending ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          if (_isSending && index == items.length) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: AuraThinkingAnimation(
                                width: 100,
                                height: 36,
                              ),
                            );
                          }
                          return AuraConversationCard(message: items[index]);
                        },
                      ),
                    ),
                    _QuickPromptBar(prompts: _quickPrompts, onPrompt: _send),
                  ],
                );
              },
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.homeScreenPadding),
                itemCount: 3,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, _) =>
                    const LoadingShimmer(width: double.infinity, height: 72),
              ),
              error: (error, _) =>
                  ErrorState(body: CustomerErrorCopy.message(error)),
            ),
          ),
          SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.65),
                    width: 0.35,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AppTextInput(
                        placeholder: 'Ask your advisor\u2026',
                        value: _controller.text,
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onChanged: (_) => setState(() {}),
                        onSubmit: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    PremiumPressable(
                      onTap: _isSending ? null : () => _send(),
                      scaleEnd: 0.92,
                      semanticLabel: 'Send message',
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _isSending
                                ? AppColors.disabledBg
                                : AppColors.ink,
                          ),
                          child: Center(
                            child: _isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.cream,
                                    ),
                                  )
                                : Icon(
                                    Icons.arrow_upward,
                                    size: 20,
                                    color: AppColors.cream.withValues(
                                      alpha: _controller.text.trim().isEmpty
                                          ? 0.45
                                          : 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPromptBar extends StatelessWidget {
  const _QuickPromptBar({required this.prompts, required this.onPrompt});

  final List<String> prompts;
  final void Function(String prompt) onPrompt;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final prompt in prompts) ...[
            GestureDetector(
              onTap: () => onPrompt(prompt),
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 0.5),
                  color: AppColors.pearl,
                ),
                child: Text(
                  prompt,
                  style: AppTypography.uiCaption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
