import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/notification.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'notifications_provider.g.dart';

class NotificationsRepository {
  const NotificationsRepository(this._apiService);

  final ApiService _apiService;

  Future<NotificationsListResponse> list({
    bool unreadOnly = false,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {
          if (unreadOnly) 'unread_only': 'true',
          'cursor': ?cursor,
          'limit': limit,
        },
      );
      return NotificationsListResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<MarkReadResponse> markRead(String notificationId) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/notifications/$notificationId/read',
      );
      return MarkReadResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<MarkAllReadResponse> markAllRead() async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/notifications/read-all',
      );
      return MarkAllReadResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<NotificationPreferences> getPreferences() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/notifications/preferences',
      );
      return NotificationPreferences.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<NotificationPreferences> updatePreferences(
    Map<String, bool> updates,
  ) async {
    try {
      final response = await _apiService.client.patch<Map<String, dynamic>>(
        '/notifications/preferences',
        data: updates,
      );
      return NotificationPreferences.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<NotificationsListResponse> notificationsList(
  Ref ref, {
  bool unreadOnly = false,
}) async {
  if (watchSignedInUserId(ref) == null) {
    return const NotificationsListResponse(
      data: [],
      unreadCount: 0,
      hasMore: false,
    );
  }

  return ref
      .watch(notificationsRepositoryProvider)
      .list(unreadOnly: unreadOnly);
}

@riverpod
Future<NotificationPreferences> notificationPreferences(Ref ref) async {
  if (watchSignedInUserId(ref) == null) {
    return const NotificationPreferences(
      pushEnabled: true,
      contributionsEnabled: true,
      milestonesEnabled: true,
      ordersEnabled: true,
      kycEnabled: true,
      auraEnabled: true,
      goldRateAlertEnabled: false,
    );
  }

  return ref.watch(notificationsRepositoryProvider).getPreferences();
}

@riverpod
class NotificationActions extends _$NotificationActions {
  @override
  FutureOr<void> build() {}

  Future<void> markRead(String notificationId) async {
    await ref.read(notificationsRepositoryProvider).markRead(notificationId);
    ref.invalidate(notificationsListProvider);
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    ref.invalidate(notificationsListProvider);
  }

  Future<NotificationPreferences> updatePreferences(
    Map<String, bool> updates,
  ) async {
    final prefs = await ref
        .read(notificationsRepositoryProvider)
        .updatePreferences(updates);
    ref.invalidate(notificationPreferencesProvider);
    return prefs;
  }
}
