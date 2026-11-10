import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/repositories/api_auth_repository.dart';
import 'package:vidsell/models/auth/login_request.dart';

void main() {
  test(
    'login and refresh send the OpenAPI Bearer header with the access token',
    () async {
      final logs = <String>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message?.startsWith('[ApiClient]') == true) logs.add(message!);
      };
      addTearDown(() => debugPrint = previousDebugPrint);

      const baseUrl = 'https://api.example.test/api/v1';
      final apiAdapter = _AuthenticatedRequestAdapter();
      final refreshAdapter = _RefreshAdapter();
      final dio = Dio(BaseOptions(baseUrl: baseUrl))
        ..httpClientAdapter = apiAdapter;
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl))
        ..httpClientAdapter = refreshAdapter;
      final sessionStore = InMemorySessionStore();
      final client = ApiClient(
        config: const AppConfig(apiBaseUrl: baseUrl, useMockBackend: false),
        sessionStore: sessionStore,
        dio: dio,
        refreshDio: refreshDio,
      );
      final authRepository = ApiAuthRepository(
        client: client,
        sessionStore: sessionStore,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
        refreshDio.close(force: true);
      });

      await authRepository.login(
        const LoginRequest(
          countryCode: '+994',
          phoneNumber: '501112233',
          password: 'test-password',
        ),
      );
      await client.get('/users/me');

      expect(apiAdapter.loginAuthorization, isNull);
      expect(apiAdapter.authenticatedAuthorizations, [
        'Bearer login-access',
        'Bearer refreshed-access',
      ]);
      expect(
        logs,
        contains(
          predicate<String>(
            (line) => line.contains('Authorization: Bearer ****(len 12)'),
          ),
        ),
      );
      expect(logs.join('\n'), isNot(contains('login-access')));
      expect(logs.join('\n'), isNot(contains('refreshed-access')));
      expect(refreshAdapter.requests.single.data, {
        'refreshToken': 'login-refresh',
      });
      final refreshedSession = await sessionStore.read();
      expect(refreshedSession?.accessToken, 'refreshed-access');
      expect(refreshedSession?.refreshToken, 'refreshed-refresh');
    },
  );
}

class _AuthenticatedRequestAdapter implements HttpClientAdapter {
  String? loginAuthorization;
  final authenticatedAuthorizations = <String?>[];
  int _profileRequests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/login') {
      loginAuthorization = options.headers['Authorization'] as String?;
      return _jsonResponse(_authResponse('login-access', 'login-refresh'));
    }

    if (options.path == '/users/me') {
      final authorization = options.headers['Authorization'] as String?;
      authenticatedAuthorizations.add(authorization);
      _profileRequests++;
      if (_profileRequests == 1) {
        return _jsonResponse({
          'code': 'TOKEN_EXPIRED',
          'message': 'Expired',
        }, statusCode: 401);
      }
      if (authorization != 'Bearer refreshed-access') {
        return _jsonResponse({
          'code': 'UNAUTHORIZED',
          'message': 'Unauthorized',
        }, statusCode: 401);
      }
      return _jsonResponse({'id': 'user-id'});
    }
    throw StateError('Unexpected ${options.method} ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

class _RefreshAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _jsonResponse(
      _authResponse('refreshed-access', 'refreshed-refresh'),
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _authResponse(String accessToken, String refreshToken) => {
  'accessToken': jsonEncode(accessToken),
  'refreshToken': refreshToken,
  'tokenType': 'Token',
  'user': {
    'id': 'user-id',
    'fullName': 'Test User',
    'countryCode': '+994',
    'phoneNumber': '501112233',
    'email': 'test@example.test',
    'gender': 'FEMALE',
    'role': 'BUYER',
    'createdAt': '2026-11-09T12:00:00Z',
  },
};

ResponseBody _jsonResponse(Object body, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
