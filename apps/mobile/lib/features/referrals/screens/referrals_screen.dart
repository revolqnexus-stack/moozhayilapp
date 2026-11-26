import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/radii.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/referral.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/referrals_provider.dart';

class ReferralsScreen extends ConsumerStatefulWidget {
  const ReferralsScreen({super.key});

  @override
  ConsumerState<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends ConsumerState<ReferralsScreen> {
  final _codeController = TextEditingController();
  bool _isApplying = false;
  String? _applyMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isApplying = true;
      _applyMessage = null;
    });

    try {
      final response = await ref
          .read(referralActionsProvider.notifier)
          .apply(code);
      setState(() => _applyMessage = response.reward);
      _codeController.clear();
    } catch (error) {
      setState(() => _applyMessage = CustomerErrorCopy.message(error));
    } finally {
      setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final referralCode = ref.watch(referralCodeProvider);
    final history = ref.watch(referralHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(title: 'Refer & Earn'),
      body: auth.when(
        data: (state) {
          if (state.step != AuthFlowStep.signedIn) {
            return EmptyState(
              icon: Icons.card_giftcard_outlined,
              headline: 'Refer friends, earn gold',
              body: 'Sign in to share your code and track referral rewards.',
              ctaLabel: 'Sign in',
              onCtaTap: () => context.push(
                Uri(
                  path: AppRoutes.auth,
                  queryParameters: {'from': AppRoutes.referrals},
                ).toString(),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              referralCode.when(
                data: (data) => _ReferralCodeCard(data: data),
                loading: () => const LoadingShimmer(
                  width: double.infinity,
                  height: AppSpacing.x3l * 2,
                ),
                error: (error, _) => ErrorState(
                  body: CustomerErrorCopy.message(error),
                  onRetry: () => ref.invalidate(referralCodeProvider),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Have a code?', style: AppTypography.headingSM),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Referral code',
                  hintText: 'PRIYA2026',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _isApplying ? null : _applyCode,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.pureWhite,
                        ),
                      )
                    : const Text('Apply code'),
              ),
              if (_applyMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(_applyMessage!, style: AppTypography.uiBodySM),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text('Referral history', style: AppTypography.headingSM),
              const SizedBox(height: AppSpacing.md),
              history.when(
                data: (response) {
                  if (response.referrals.isEmpty) {
                    return const EmptyState(
                      headline: 'No referrals yet',
                      body: 'Share your code to start earning gold credit.',
                    );
                  }

                  return Column(
                    children: response.referrals
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: _ReferralHistoryCard(item: item),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const LoadingShimmer(
                  width: double.infinity,
                  height: AppSpacing.x3l,
                ),
                error: (error, _) => ErrorState(
                  body: CustomerErrorCopy.message(error),
                  onRetry: () => ref.invalidate(referralHistoryProvider),
                ),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: LoadingShimmer(width: double.infinity, height: AppSpacing.x3l),
        ),
        error: (error, _) => ErrorState(body: CustomerErrorCopy.message(error)),
      ),
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  const _ReferralCodeCard({required this.data});

  final ReferralCodeResponse data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.champagneVeil,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.smokeLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your referral code', style: AppTypography.uiLabel),
          const SizedBox(height: AppSpacing.sm),
          Text(data.referralCode, style: AppTypography.headingLG),
          const SizedBox(height: AppSpacing.xs),
          Text(data.rewardDescription, style: AppTypography.uiBodySM),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${data.successfulReferrals} rewarded · ${data.pendingReferrals} pending',
            style: AppTypography.uiCaption,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              OutlinedButton(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: data.referralCode)),
                child: const Text('Copy code'),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: data.shareUrl)),
                child: const Text('Copy link'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferralHistoryCard extends StatelessWidget {
  const _ReferralHistoryCard({required this.item});

  final ReferralHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.smokeLine),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.referralCode, style: AppTypography.uiBodyMD),
              Text(item.status, style: AppTypography.uiCaption),
            ],
          ),
          if (item.rewardValueDisplay != null)
            Text(item.rewardValueDisplay!, style: AppTypography.priceMD),
        ],
      ),
    );
  }
}
