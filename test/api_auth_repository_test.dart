import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/repositories/api_auth_repository.dart';
import 'package:vidsell/models/auth/login_request.dart';
import 'package:vidsell/models/auth/register_request.dart';
import 'package:vidsell/models/auth/reset_password_request.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';
import 'package:vidsell/models/auth/verify_otp_request.dart';
import 'package:vidsell/models/enums/gender.dart';
import 'package:vidsell/models/enums/role.dart';

void main() {
  test(
    'auth calls exact OpenAPI routes, bodies, reset token, and sessions',
    () async {
      final adapter = _AuthAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
      dio.httpClientAdapter = adapter;
      final sessionStore = InMemorySessionStore();
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api/v1',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });
      final repository = ApiAuthRepository(
        client: client,
        sessionStore: sessionStore,
      );

      await repository.sendOtp(
        const SendOtpRequest(countryCode: '+994', phoneNumber: '501112233'),
      );
      final registered = await repository.register(
        const RegisterRequest(
          fullName: 'Test User',
          countryCode: '+994',
          phoneNumber: '501112233',
          email: 'test@example.test',
          password: 'password-8',
          gender: Gender.female,
          termsAccepted: true,
          role: Role.buyer,
          verificationCode: '780423',
        ),
      );
      expect(registered.user.fullName, 'Test User');
      expect((await sessionStore.read())?.accessToken, registered.accessToken);

      await repository.requestPasswordReset(
        const SendOtpRequest(countryCode: '+994', phoneNumber: '501112233'),
      );
      final reset = await repository.verifyOtp(
        const VerifyOtpRequest(
          countryCode: '+994',
          phoneNumber: '501112233',
          code: '5678',
        ),
      );
      expect(reset.resetToken, 'reset-token-fixture');
      await repository.resetPassword(
        ResetPasswordRequest(
          resetToken: reset.resetToken,
          newPassword: 'new-password',
        ),
      );

      final loggedIn = await repository.login(
        const LoginRequest(
          countryCode: '+994',
          phoneNumber: '501112233',
          password: 'new-password',
        ),
      );
      final storedSession = await sessionStore.read();
      expect(storedSession?.accessToken, loggedIn.accessToken);
      expect(storedSession?.refreshToken, loggedIn.refreshToken);
      expect(storedSession?.user.fullName, 'Test User');

      expect(adapter.requests.map((request) => request.method), [
        'POST',
        'POST',
        'POST',
        'POST',
        'POST',
        'POST',
      ]);
      expect(adapter.requests.map((request) => request.path), [
        '/auth/send-registration-otp',
        '/auth/register',
        '/auth/forgot-password',
        '/auth/verify-otp',
        '/auth/reset-password',
        '/auth/login',
      ]);
      expect(
        adapter.requests.map((request) => request.headers['X-App-Language']),
        everyElement('tr'),
      );
      expect(adapter.requests[0].data, {
        'countryCode': '+994',
        'phoneNumber': '501112233',
      });
      expect(adapter.requests[1].data, {
        'fullName': 'Test User',
        'countryCode': '+994',
        'phoneNumber': '501112233',
        'password': 'password-8',
        'email': 'test@example.test',
        'gender': 'FEMALE',
        'termsAccepted': true,
        'role': 'BUYER',
        'verificationCode': '780423',
      });
      expect(adapter.requests[2].data, {
        'countryCode': '+994',
        'phoneNumber': '501112233',
      });
      expect(adapter.requests[3].data, {
        'countryCode': '+994',
        'phoneNumber': '501112233',
        'code': '5678',
      });
      expect(adapter.requests[4].data, {
        'resetToken': 'reset-token-fixture',
        'newPassword': 'new-password',
      });
      expect(adapter.requests[5].data, {
        'countryCode': '+994',
        'phoneNumber': '501112233',
        'password': 'new-password',
      });
    },
  );
}

class _AuthAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = switch (options.path) {
      '/auth/send-registration-otp' => {'message': 'OTP sent'},
      '/auth/register' => _authResponse('registration'),
      '/auth/forgot-password' => {'message': 'sent'},
      '/auth/verify-otp' => {'resetToken': 'reset-token-fixture'},
      '/auth/reset-password' => {'message': 'updated'},
      '/auth/login' => _authResponse('login'),
      _ => throw StateError('Unexpected auth route: ${options.path}'),
    };
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  Map<String, dynamic> _authResponse(String key) => {
    'accessToken': base64Url.encode(utf8.encode('access-$key')),
    'refreshToken': base64Url.encode(utf8.encode('refresh-$key')),
    'tokenType': 'Bearer',
    'user': {
      'id': '00000000-0000-4000-8000-000000000001',
      'fullName': 'Test User',
      'countryCode': '+994',
      'phoneNumber': '501112233',
      'email': 'test@example.test',
      'avatarUrl': 'https://example.test/avatar.png',
      'gender': 'FEMALE',
      'role': 'BUYER',
      'createdAt': '2026-11-09T12:00:00Z',
    },
  };

  @override
  void close({bool force = false}) {}
}
