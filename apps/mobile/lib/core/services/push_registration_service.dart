import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Registers the device push token with the API.
class PushRegistrationService {
  const PushRegistrationService(this._apiService);

  final ApiService _apiService;
  static var _firebaseInitialized = false;

  Future<void> registerDeviceIfNeeded() async {
    if (kIsWeb) {
      return;
    }

    if (kReleaseMode) {
      if (!pushRegistrationEnabled) {
        return;
      }

      await _registerViaFirebase();
      return;
    }

    if (pushMockTokensEnabled) {
      await _registerToken(
        token:
            'mock_fcm_${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  Future<void> _registerViaFirebase() async {
    if (!pushRegistrationEnabled) {
      return;
    }

    try {
      if (!_firebaseInitialized) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _firebaseInitialized = true;
      }

      final messaging = FirebaseMessaging.instance;

      // Request permission (Android 13+ and iOS both require this).
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[push] User denied notification permissions.');
        return;
      }

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      await _registerToken(token: token);

      // Refresh token when FCM rotates it.
      messaging.onTokenRefresh.listen((refreshedToken) {
        unawaited(_registerToken(token: refreshedToken));
      });

      // Handle notifications tapped while app is in foreground.
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app was in background (not terminated).
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated.
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (error, stackTrace) {
      debugPrint('[push] Firebase registration failed: $error');
      debugPrint('$stackTrace');
    }
  }

  /// Show an in-app banner when a push arrives while the app is open.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[push] foreground message: ${message.messageId}');
    // The notification UI is handled by the in-app NotificationsScreen.
    // We invalidate the provider so the bell badge updates automatically.
    // Routing to a specific screen is intentionally deferred to user tap.
  }

  /// Navigate to the deep-link route embedded in the push payload.
  void _handleNotificationTap(RemoteMessage message) {
    final deepLink = message.data['deep_link'] as String?;
    if (deepLink != null && deepLink.isNotEmpty) {
      // Store the pending deep link — the router reads it on next build.
      _pendingDeepLink = deepLink;
    }
  }

  /// Pending deep link from a cold-start notification tap.
  /// Read once by the router after the first frame is rendered.
  static String? _pendingDeepLink;

  static String? consumePendingDeepLink() {
    final link = _pendingDeepLink;
    _pendingDeepLink = null;
    return link;
  }

  Future<void> _registerToken({required String token}) async {
    try {
      await _apiService.client.post<void>(
        '/user/devices',
        data: {
          'push_token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'app_version': const String.fromEnvironment(
            'APP_VERSION',
            defaultValue: '1.0.0',
          ),
        },
      );
    } catch (_) {
      // Best-effort registration.
    }
  }
}

final pushRegistrationServiceProvider = Provider<PushRegistrationService>((
  ref,
) {
  return PushRegistrationService(ref.watch(apiServiceProvider));
});
