import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moozhayil/app.dart';
import 'package:moozhayil/core/widgets/app_error_widget.dart';
import 'package:moozhayil/firebase_options.dart';

/// Top-level FCM background message handler.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // The notification is handled by the system tray automatically.
  // We only need this handler if we want to process data-only messages
  // while the app is terminated.
  debugPrint('[FCM background] message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Release builds must use bundled fonts — no runtime CDN fetch on device.
  if (kReleaseMode) {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  // Lock to portrait — jewellery browsing is portrait-native.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Register FCM background handler before Firebase.initializeApp.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return AppErrorWidget(details: details);
  };

  runApp(const ProviderScope(child: MoozhayilApp()));
}
