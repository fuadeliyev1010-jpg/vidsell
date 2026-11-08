import 'package:vidsell/core/network/mock_api_client.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/repositories/auth_repository.dart';
import 'package:vidsell/models/auth/login_request.dart';
import 'package:vidsell/models/auth/register_request.dart';
import 'package:vidsell/models/auth/reset_password_request.dart';
import 'package:vidsell/models/auth/reset_token_response.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';
import 'package:vidsell/models/auth/verify_otp_request.dart';
import 'package:vidsell/models/user/user.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({MockApiClient? client, SessionStore? sessionStore})
    : _client = client ?? MockApiClient(sessionStore: sessionStore);

  final MockApiClient _client;

  @override
  Stream<void> get onSessionExpired => const Stream<void>.empty();

  @override
  Future<void> sendOtp(SendOtpRequest request) =>
      _client.sendOtp(request.phoneNumber);

  @override
  Future<User?> verifyOtp(VerifyOtpRequest request) {
    return _client.verifyOtp(
      identifier: request.phoneNumber,
      code: request.code,
    );
  }

  @override
  Future<AuthSession> register(RegisterRequest request) {
    return _client.register(
      identifier: '${request.countryCode}${request.phoneNumber}',
      name: request.fullName,
      email: request.email,
      password: request.password,
    );
  }

  @override
  Future<AuthSession> loginAfterOtp({
    required String identifier,
    required User user,
  }) {
    return _client.loginAfterOtp(identifier: identifier, user: user);
  }

  @override
  Future<AuthSession> login(LoginRequest request) => _client.login(
    identifier: request.phoneNumber,
    password: request.password,
  );

  @override
  Future<ResetTokenResponse> requestPasswordReset(
    SendOtpRequest request,
  ) async => const ResetTokenResponse(resetToken: 'mock-reset-token');

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {}

  @override
  Future<AuthSession?> restoreSession() => _client.restoreSession();

  @override
  Future<void> logout() => _client.logout();
}
