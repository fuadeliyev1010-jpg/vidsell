import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/models/user/user.dart';

void main() {
  test('retry 401 retains refreshed session for later requests', () async {
    final requestAdapter = _RetryUnauthorizedAdapter();
    final refreshAdapter = _SuccessfulRefreshAdapter();
    final (client, sessionStore, dio, refreshDio) = await _createClient(
      requestAdapter,
      refreshAdapter,
    );
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
      refreshDio.close(force: true);
    });

    await expectLater(
      client.get('/legacy/resource'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );

    final refreshedSession = await sessionStore.read();
    expect(refreshedSession?.accessToken, 'fresh-access');
    expect(refreshedSession?.refreshToken, 'fresh-refresh');
    expect(requestAdapter.headersFor('/legacy/resource'), [
      'Bearer stale-access',
      'Bearer fresh-access',
    ]);

    expect(await client.get('/users/me'), {'id': 'user-id'});
    expect(requestAdapter.lastHeaderFor('/users/me'), 'Bearer fresh-access');
    expect(refreshAdapter.requests, hasLength(1));
  });

  test(
    'concurrent 401s share one refresh and do not retry in a loop',
    () async {
      final requestAdapter = _AlwaysUnauthorizedAdapter();
      final refreshAdapter = _SuccessfulRefreshAdapter(
        delay: const Duration(milliseconds: 25),
      );
      final (client, sessionStore, dio, refreshDio) = await _createClient(
        requestAdapter,
        refreshAdapter,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
        refreshDio.close(force: true);
      });

      await Future.wait([
        _expectUnauthorized(client.get('/resource/one')),
        _expectUnauthorized(client.get('/resource/two')),
        _expectUnauthorized(client.get('/resource/three')),
      ]);

      expect(refreshAdapter.requests, hasLength(1));
      expect(requestAdapter.requests, hasLength(6));
      expect(
        requestAdapter.requests
            .map((request) => request.headers['Authorization'])
            .where((header) => header == 'Bearer fresh-access'),
        hasLength(3),
      );
      expect((await sessionStore.read())?.accessToken, 'fresh-access');
    },
  );
}

Future<void> _expectUnauthorized(Future<dynamic> request) async {
  await expectLater(
    request,
    throwsA(
      isA<ApiException>().having(
        (error) => error.statusCode,
        'statusCode',
        401,
      ),
    ),
  );
}

Future<(ApiClient, InMemorySessionStore, Dio, Dio)> _createClient(
  HttpClientAdapter requestAdapter,
  HttpClientAdapter refreshAdapter,
) async {
  const baseUrl = 'https://api.example.test/api/v1';
  final dio = Dio(BaseOptions(baseUrl: baseUrl))
    ..httpClientAdapter = requestAdapter;
  final refreshDio = Dio(BaseOptions(baseUrl: baseUrl))
    ..httpClientAdapter = refreshAdapter;
  final sessionStore = InMemorySessionStore();
  await sessionStore.write(
    const AuthSession(
      accessToken: 'stale-access',
      refreshToken: 'stale-refresh',
      user: User(id: 'user-id'),
    ),
  );
  final client = ApiClient(
    config: const AppConfig(apiBaseUrl: baseUrl, useMockBackend: false),
    sessionStore: sessionStore,
    dio: dio,
    refreshDio: refreshDio,
  );
  return (client, sessionStore, dio, refreshDio);
}

class _RetryUnauthorizedAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  List<String?> headersFor(String path) => requests
      .where((request) => request.path == path)
      .map((request) => request.headers['Authorization'] as String?)
      .toList();

  String? lastHeaderFor(String path) => requests
      .where((request) => request.path == path)
      .map((request) => request.headers['Authorization'] as String?)
      .lastOrNull;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/users/me' &&
        options.headers['Authorization'] == 'Bearer fresh-access') {
      return _jsonResponse({'id': 'user-id'});
    }
    return _unauthorized();
  }

  @override
  void close({bool force = false}) {}
}

class _AlwaysUnauthorizedAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return _unauthorized();
  }

  @override
  void close({bool force = false}) {}
}

class _SuccessfulRefreshAdapter implements HttpClientAdapter {
  _SuccessfulRefreshAdapter({this.delay = Duration.zero});

  final Duration delay;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    return _jsonResponse({
      'accessToken': 'fresh-access',
      'refreshToken': 'fresh-refresh',
      'tokenType': 'Bearer',
    });
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _unauthorized() => _jsonResponse({
  'code': 'UNAUTHORIZED',
  'message': 'Unauthorized',
}, statusCode: 401);

ResponseBody _jsonResponse(Object body, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
