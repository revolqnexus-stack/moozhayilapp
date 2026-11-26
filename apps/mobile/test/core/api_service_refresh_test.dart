import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/services/api_service.dart';
import 'package:moozhayil/core/services/storage_service.dart';

/// In-memory token store; records whether tokens were cleared.
class FakeStorage extends StorageService {
  FakeStorage({this.access, this.refresh})
    : super(const FlutterSecureStorage());

  String? access;
  String? refresh;
  int clearCount = 0;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveAccessToken(String accessToken) async {
    access = accessToken;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    clearCount++;
    access = null;
    refresh = null;
  }
}

typedef Responder = FutureOr<ResponseBody> Function(RequestOptions options);

/// Fake transport: routes requests to [responder] and logs every call.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.responder);

  final Responder responder;
  final calls = <RequestOptions>[];

  int countPath(String path) => calls.where((c) => c.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ResponseBody apiError(int status, String code) => json(status, {
  'error': {'code': code, 'message': code},
});

String? bearer(RequestOptions o) =>
    (o.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');

({ApiService api, FakeAdapter adapter, FakeStorage storage}) build(
  Responder responder, {
  String? access = 'expired',
  String? refresh = 'refresh-1',
}) {
  final adapter = FakeAdapter(responder);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/v1'))
    ..httpClientAdapter = adapter;
  final storage = FakeStorage(access: access, refresh: refresh);
  return (
    api: ApiService(dio: dio, storageService: storage),
    adapter: adapter,
    storage: storage,
  );
}

/// Server where only `fresh` is a valid access token.
FutureOr<ResponseBody> standardServer(RequestOptions o) {
  if (o.path == '/auth/refresh') {
    return json(200, {'access_token': 'fresh', 'expires_in': 86400});
  }
  if (bearer(o) != 'fresh') {
    return apiError(401, 'UNAUTHORIZED');
  }
  return json(200, {'ok': true, 'path': o.path});
}

void main() {
  test('expired token: refreshes once, retries, request succeeds', () async {
    final t = build(standardServer);

    final res = await t.api.client.get<Map<String, dynamic>>('/user/me');

    expect(res.data!['ok'], isTrue);
    expect(t.adapter.countPath('/auth/refresh'), 1);
    expect(t.storage.access, 'fresh');
    expect(t.storage.clearCount, 0);
  });

  test('10 concurrent requests with an expired token all succeed', () async {
    final t = build(standardServer);
    const paths = [
      '/user/me',
      '/kyc/status',
      '/cart',
      '/goals',
      '/orders',
      '/gold-balance',
      '/vault',
      '/notifications',
      '/addresses',
      '/referrals',
    ];

    final results = await Future.wait(
      paths.map((p) => t.api.client.get<Map<String, dynamic>>(p)),
    ).timeout(const Duration(seconds: 5)); // a deadlock would hang here

    expect(results.map((r) => r.data!['path']), paths);
    expect(t.storage.access, 'fresh');
    expect(t.storage.clearCount, 0);
    // Each queued 401 currently performs its own refresh (server does not
    // rotate refresh tokens, so this is redundant but safe).
    expect(t.adapter.countPath('/auth/refresh'), inInclusiveRange(1, 10));
  });

  test(
    'retried request failing again does not hang (deadlock regression)',
    () async {
      final t = build((o) {
        if (o.path == '/auth/refresh') {
          return json(200, {'access_token': 'fresh', 'expires_in': 86400});
        }
        if (bearer(o) != 'fresh') return apiError(401, 'UNAUTHORIZED');
        return apiError(500, 'INTERNAL');
      });

      final future = t.api.client.get<dynamic>('/user/me');

      await expectLater(
        future.timeout(const Duration(seconds: 5)),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            500,
          ),
        ),
      );
      expect(t.storage.clearCount, 0);
    },
  );

  test('403 from a KYC-gated route after refresh keeps the session', () async {
    final t = build((o) {
      if (o.path == '/auth/refresh') {
        return json(200, {'access_token': 'fresh', 'expires_in': 86400});
      }
      if (bearer(o) != 'fresh') return apiError(401, 'UNAUTHORIZED');
      return apiError(403, 'KYC_REQUIRED');
    });

    await expectLater(
      t.api.client.get<dynamic>('/gold-balance/redeem'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          403,
        ),
      ),
    );
    expect(t.storage.clearCount, 0);
    expect(t.storage.access, 'fresh');
    expect(t.storage.refresh, 'refresh-1');
  });

  test('invalid or expired refresh token clears the session', () async {
    final t = build((o) {
      if (o.path == '/auth/refresh') return apiError(401, 'UNAUTHORIZED');
      return apiError(401, 'UNAUTHORIZED');
    });

    await expectLater(
      t.api.client.get<dynamic>('/user/me'),
      throwsA(isA<DioException>()),
    );
    expect(t.storage.clearCount, 1);
    expect(t.storage.refresh, isNull);
  });

  test('network failure during refresh keeps the session', () async {
    final t = build((o) {
      if (o.path == '/auth/refresh') {
        throw DioException.connectionError(
          requestOptions: o,
          reason: 'offline',
        );
      }
      return apiError(401, 'UNAUTHORIZED');
    });

    await expectLater(
      t.api.client.get<dynamic>('/user/me'),
      throwsA(isA<DioException>()),
    );
    expect(t.storage.clearCount, 0);
    expect(t.storage.refresh, 'refresh-1');
  });

  test('server 5xx during refresh keeps the session', () async {
    final t = build((o) {
      if (o.path == '/auth/refresh') return apiError(503, 'UNAVAILABLE');
      return apiError(401, 'UNAUTHORIZED');
    });

    await expectLater(
      t.api.client.get<dynamic>('/user/me'),
      throwsA(isA<DioException>()),
    );
    expect(t.storage.clearCount, 0);
  });

  test('429 and 5xx on normal requests do not trigger a refresh', () async {
    for (final status in [429, 500, 503]) {
      final t = build((o) => apiError(status, 'X'), access: 'fresh');

      await expectLater(
        t.api.client.get<dynamic>('/cart'),
        throwsA(isA<DioException>()),
      );
      expect(t.adapter.countPath('/auth/refresh'), 0, reason: '$status');
      expect(t.storage.clearCount, 0, reason: '$status');
    }
  });

  test('no refresh token: 401 is passed through without clearing', () async {
    final t = build(standardServer, refresh: null);

    await expectLater(
      t.api.client.get<dynamic>('/user/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(t.adapter.countPath('/auth/refresh'), 0);
  });
}
