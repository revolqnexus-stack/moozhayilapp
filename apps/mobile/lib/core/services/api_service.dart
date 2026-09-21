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

    try {
      final refreshDio = Dio(_dio.options);
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final result = RefreshTokenResult.fromJson(response.data!);
      await _storageService.saveAccessToken(result.accessToken);

      final request = error.requestOptions;
      request.extra['auth_retry'] = true;
      request.headers['Authorization'] = 'Bearer ${result.accessToken}';

      final retried = await _dio.fetch<dynamic>(request);
      handler.resolve(retried);
    } on DioException catch (refreshError) {
      await _storageService.clearTokens();
      handler.next(refreshError);
    } catch (_) {
      await _storageService.clearTokens();
      handler.next(error);
    }
  }
}

@riverpod
Dio dio(Ref ref) {
  final clock = ref.watch(serverClockProvider);
  final client = Dio(
    BaseOptions(
      baseUrl: resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
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

@riverpod
ApiService apiService(Ref ref) {
  return ApiService(
    dio: ref.watch(dioProvider),
    storageService: ref.watch(storageServiceProvider),
  );
}
