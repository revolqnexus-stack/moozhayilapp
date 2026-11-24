// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/api_config.dart';
import '../models/auth_models.dart';
import '../time/server_clock_provider.dart';
import 'storage_service.dart';

part 'api_service.g.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.details});

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final apiError = data['error'];
      if (apiError is Map<String, dynamic>) {
        return ApiException(
          apiError['message'] as String? ?? 'Something went wrong',
          code: apiError['code'] as String?,
          details: apiError['details'] as Map<String, dynamic>?,
        );
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      return const ApiException('Please check your internet connection');
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        'The server is waking up. Please wait a moment and try again.',
      );
    }

    return const ApiException('Something went wrong');
  }

  @override
  String toString() => message;
}

class ApiService {
  ApiService({required Dio dio, required StorageService storageService})
    : _dio = dio,
      _storageService = storageService {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _attachAccessToken,
        onError: _refreshAndRetry,
      ),
    );
  }

  final Dio _dio;
  final StorageService _storageService;

  Dio get client => _dio;

  Future<void> _attachAccessToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _refreshAndRetry(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final status = error.response?.statusCode;
    final alreadyRetried = error.requestOptions.extra['auth_retry'] == true;

    if (status != 401 || alreadyRetried) {
      handler.next(error);
      return;
    }

    final refreshToken = await _storageService.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(error);
      return;
    }

    // A plain Dio (no queued interceptors) for both the refresh call and the
    // retry. Retrying through `_dio` would deadlock: if the retried request
    // also fails, its onError is queued behind this still-running handler,
    // so the original request never completes (endless spinner).
    final plainDio = Dio(_dio.options)
      ..httpClientAdapter = _dio.httpClientAdapter;

    final String accessToken;
    try {
      final response = await plainDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      accessToken = RefreshTokenResult.fromJson(response.data!).accessToken;
      await _storageService.saveAccessToken(accessToken);
    } on DioException catch (refreshError) {
      if (_refreshFailureInvalidatesSession(refreshError)) {
        await _storageService.clearTokens();
      }
      handler.next(refreshError);
      return;
    } catch (_) {
      handler.next(error);
      return;
    }

    // Failures of the retried request are ordinary API errors (e.g. a 403 from
    // a KYC-gated route) and must not wipe the freshly refreshed session.
    final request = error.requestOptions;
    request.extra['auth_retry'] = true;
    request.headers['Authorization'] = 'Bearer $accessToken';
    try {
      handler.resolve(await plainDio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(error);
    }
  }

  /// Wipe session only when the refresh token is rejected — not on timeouts/5xx.
  bool _refreshFailureInvalidatesSession(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return true;
    }
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final apiError = data['error'];
      if (apiError is Map<String, dynamic>) {
        final code = apiError['code'] as String?;
        if (code == 'UNAUTHORIZED' || code == 'INVALID_REFRESH_TOKEN') {
          return true;
        }
      }
    }
    return false;
  }
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final clock = ref.watch(serverClockProvider);
  final client = Dio(
    BaseOptions(
      baseUrl: resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 25),
      responseType: ResponseType.json,
    ),
  );

  client.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        clock.syncFromHttpDate(
          response.headers.value('date'),
          ageHeader: response.headers.value('age'),
        );
        handler.next(response);
      },
    ),
  );

  return client;
}

// keepAlive: a single client so token refreshes are queued in one place.
@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) {
  return ApiService(
    dio: ref.watch(dioProvider),
    storageService: ref.watch(storageServiceProvider),
  );
}
