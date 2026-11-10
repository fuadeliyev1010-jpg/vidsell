import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/repositories/api_auth_repository.dart';
import 'package:vidsell/models/user/user.dart';

void main() {
  test(
    'failed refresh clears the session and expires authenticated state',
    () async {
      const baseUrl = 'https://api.example.test/api/v1';
      final requestAdapter = _UnauthorizedAdapter();
      final refreshAdapter = _UnauthorizedAdapter();
      final dio = Dio(BaseOptions(baseUrl: baseUrl))
        ..httpClientAdapter = requestAdapter;
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl))
        ..httpClientAdapter = refreshAdapter;
      final sessionStore = InMemorySessionStore();
      await sessionStore.write(
        const AuthSession(
          accessToken: 'expired-access-token',
          refreshToken: 'invalid-refresh-token',
          user: User(id: 'user-id'),
        ),
      );
      final client = ApiClient(
        config: const AppConfig(apiBaseUrl: baseUrl, useMockBackend: false),
        sessionStore: sessionStore,
        dio: dio,
        refreshDio: refreshDio,
      );
      final authBloc = AuthBloc(
        repository: ApiAuthRepository(
          client: client,
          sessionStore: sessionStore,
        ),
      );
      addTearDown(() async {
        await authBloc.close();
        client.dispose();
        dio.close(force: true);
        refreshDio.close(force: true);
      });

      final unauthenticated = authBloc.stream.firstWhere(
        (state) => state.status == AuthStatus.unauthenticated,
      );
      await expectLater(
        client.get('/users/me'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );

      final state = await unauthenticated;
      expect(state.status, AuthStatus.unauthenticated);
      expect(await sessionStore.read(), isNull);
      expect(requestAdapter.requests.single.path, '/users/me');
      expect(refreshAdapter.requests.single.path, '/auth/refresh');
    },
  );
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'status': 401,
        'code': 'UNAUTHORIZED',
        'message': 'Unauthorized',
      }),
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
