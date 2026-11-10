import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/api_exception.dart';

void main() {
  test('logs HTTP errors without exposing submitted credentials', () async {
    final logs = _captureApiClientLogs();
    final adapter = _DiagnosticsAdapter(
      statusCode: 422,
      body: {
        'code': 'INVALID_OTP',
        'message':
            'OTP 123456 is invalid for password hunter2 and token secret-token',
      },
    );
    final (client, dio) = _createClient(adapter);
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
    });

    late ApiException apiException;
    try {
      await client.post(
        '/auth/otp',
        data: {
          'otp': '123456',
          'password': 'hunter2',
          'refreshToken': 'secret-token',
        },
      );
      fail('Expected the request to fail.');
    } on ApiException catch (error) {
      apiException = error;
    }

    expect(apiException.statusCode, 422);
    expect(apiException.code, 'INVALID_OTP');
    expect(apiException.underlyingType, DioExceptionType.badResponse);
    expect(apiException.message, contains('123456'));
    expect(logs, hasLength(1));
    expect(
      logs.single,
      contains('POST https://api.example.test/api/v1/auth/otp'),
    );
    expect(logs.single, contains('status=422'));
    expect(logs.single, contains('duration='));
    expect(logs.single, contains('code=INVALID_OTP'));
    expect(logs.single, contains('dioType=badResponse'));
    expect(logs.single, isNot(contains('123456')));
    expect(logs.single, isNot(contains('hunter2')));
    expect(logs.single, isNot(contains('secret-token')));
  });

  test(
    'logs connection errors with their Dio type and no HTTP status',
    () async {
      final logs = _captureApiClientLogs();
      final adapter = _DiagnosticsAdapter(
        exceptionType: DioExceptionType.connectionError,
      );
      final (client, dio) = _createClient(adapter);
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      late ApiException apiException;
      try {
        await client.get('/users/me');
        fail('Expected the request to fail.');
      } on ApiException catch (error) {
        apiException = error;
      }

      expect(apiException.statusCode, isNull);
      expect(apiException.code, 'connectionError');
      expect(apiException.underlyingType, DioExceptionType.connectionError);
      expect(logs, hasLength(1));
      expect(
        logs.single,
        contains('GET https://api.example.test/api/v1/users/me'),
      );
      expect(logs.single, contains('status=-'));
      expect(logs.single, contains('dioType=connectionError'));
    },
  );
}

List<String> _captureApiClientLogs() {
  final logs = <String>[];
  final previousDebugPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message?.startsWith('[ApiClient]') == true) logs.add(message!);
  };
  addTearDown(() => debugPrint = previousDebugPrint);
  return logs;
}

(ApiClient, Dio) _createClient(_DiagnosticsAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
  dio.httpClientAdapter = adapter;
  final client = ApiClient(
    config: const AppConfig(
      apiBaseUrl: 'https://api.example.test/api/v1',
      useMockBackend: false,
    ),
    dio: dio,
  );
  return (client, dio);
}

class _DiagnosticsAdapter implements HttpClientAdapter {
  _DiagnosticsAdapter({this.statusCode = 200, this.body, this.exceptionType});

  final int statusCode;
  final Object? body;
  final DioExceptionType? exceptionType;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final exceptionType = this.exceptionType;
    if (exceptionType != null) {
      throw DioException(
        requestOptions: options,
        type: exceptionType,
        message: 'Connection failed',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
