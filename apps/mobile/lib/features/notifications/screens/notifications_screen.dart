import 'package:flutter/material.dart';
import '../../../core/utils/customer_error_copy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/empty_state.dart';
import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../core/animations/staggered_list_item.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/motion.dart';
import '../../../components/editorial/editorial_panel.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/notification.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final notifications = ref.watch(notificationsListProvider());

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppTopBar.detail(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all read',
            onPressed: () =>
                ref.read(notificationActionsProvider.notifier).markAllRead(),
          ),
        ],
      ),
      body: auth.when(
        data: (state) {
          if (state.step != AuthFlowStep.signedIn) {
            return EmptyState(
              icon: Icons.notifications_outlined,
              headline: 'No notifications',
              body: 'Sign in to see updates about your plans and orders.',
              ctaLabel: 'Sign in',
              onCtaTap: () => context.push(
                Uri(
                  path: AppRoutes.auth,
                  queryParameters: {'from': AppRoutes.notifications},
                ).toString(),
              ),
            );
          }

          return notifications.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const EmptyState(
                  icon: Icons.notifications_outlined,
                  headline: 'You\'re all caught up.',
                  body:
                      'We\'ll notify you about installments, milestones, and orders.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(notificationsListProvider);
                  await ref.read(notificationsListProvider().future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: response.data.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final staggerIndex = index > 8 ? 8 : index;
                    return StaggeredListItem(
                      index: staggerIndex,
                      child: _NotificationCard(
                        notification: response.data[index],
                        onTap: () =>
                            _handleTap(context, ref, response.data[index]),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: LoadingShimmer(
                width: double.infinity,
                height: AppSpacing.x3l * 2,
              ),
            ),
            error: (error, _) => ErrorState(
              body: CustomerErrorCopy.message(error),
              onRetry: () => ref.invalidate(notificationsListProvider),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(body: CustomerErrorCopy.message(error)),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      await ref
          .read(notificationActionsProvider.notifier)
          .markRead(notification.id);
    }

    final deepLink = notification.deepLink;
    if (deepLink != null && deepLink.isNotEmpty && context.mounted) {
      context.push(deepLink);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EditorialPanel(
      onTap: onTap,
      color: notification.isRead ? AppColors.bgWhite : AppColors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: AppTypography.uiBodyMD.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: AppMotion.stateTransition,
                child: notification.isRead
                    ? const SizedBox.shrink(key: ValueKey('read'))
                    : Container(
                        key: const ValueKey('unread'),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(notification.body, style: AppTypography.uiBodySM),
        ],
      ),
    );
  }
}
