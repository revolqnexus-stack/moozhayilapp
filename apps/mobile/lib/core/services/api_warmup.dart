import 'package:dio/dio.dart';

import '../config/api_config.dart';

/// Wakes Render (free tier sleeps after ~15 min idle). Fire-and-forget on login.
Future<void> warmProductionApi({
  Duration timeout = const Duration(seconds: 12),
}) async {
  final base = resolveApiBaseUrl();
  if (!base.startsWith('https://')) {
    return;
  }
  final origin = base.replaceFirst(RegExp(r'/v1/?$'), '');
  final client = Dio(
    BaseOptions(connectTimeout: timeout, receiveTimeout: timeout),
  );
  try {
    await client.get<dynamic>('$origin/health');
  } catch (_) {
    // Best-effort; send-otp will retry.
  }
}
