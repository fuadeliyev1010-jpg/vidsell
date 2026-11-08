import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/auth/repositories/auth_repository.dart';
import 'package:vidsell/models/auth/auth_response.dart';
import 'package:vidsell/models/auth/login_request.dart';
import 'package:vidsell/models/auth/register_request.dart';
import 'package:vidsell/models/auth/reset_password_request.dart';
import 'package:vidsell/models/auth/reset_token_response.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';
import 'package:vidsell/models/auth/verify_otp_request.dart';
import 'package:vidsell/models/user/user.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required ApiClient client,
    required SessionStore sessionStore,
  }) : _client = client,
       _sessionStore = sessionStore;

  final ApiClient _client;
  final SessionStore _sessionStore;

  @override
  Stream<void> get onSessionExpired => _client.onSessionExpired;

  @override
  Future<void> sendOtp(SendOtpRequest request) async {
    await _client.post('/auth/otp/request', data: request.toJson());
  }

  @override
  Future<User?> verifyOtp(VerifyOtpRequest request) async {
    final data = await _client.post('/auth/otp/verify', data: request.toJson());
    if (data is! Map<String, dynamic> || data['user'] == null) return null;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthSession> register(RegisterRequest request) async {
    final session = await _authenticate('/auth/register', request.toJson());
    final user = session.user.copyWith(
      identifier: session.user.identifier.isEmpty
          ? '${request.countryCode}${request.phoneNumber}'
          : session.user.identifier,
      name: session.user.name.isEmpty ? request.fullName : session.user.name,
      email: session.user.email.isEmpty ? request.email : session.user.email,
      phoneNumber: session.user.phoneNumber.isEmpty
          ? request.phoneNumber
          : session.user.phoneNumber,
    );
    final registeredSession = session.copyWith(user: user);
    await _sessionStore.write(registeredSession);
    return registeredSession;
  }

  @override
  Future<AuthSession> loginAfterOtp({
    required String identifier,
    required User user,
  }) => _authenticate('/auth/otp/login', {
    'identifier': identifier,
    'userId': user.id,
  });

  @override
  Future<AuthSession> login(LoginRequest request) =>
      _authenticate('/auth/login', request.toJson());

  @override
  Future<ResetTokenResponse> requestPasswordReset(
    SendOtpRequest request,
  ) async {
    final data = await _client.post(
      '/auth/password/reset/request',
      data: request.toJson(),
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid password reset response.');
    }
    return ResetTokenResponse.fromJson(data);
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await _client.post('/auth/password/reset', data: request.toJson());
  }

  @override
  Future<AuthSession?> restoreSession() => _sessionStore.read();

  @override
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _sessionStore.clear();
    }
  }

  Future<AuthSession> _authenticate(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final data = await _client.post(path, data: payload);
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid authentication response.');
    }
    final session = AuthSession.fromAuthResponse(AuthResponse.fromJson(data));
    await _sessionStore.write(session);
    return session;
  }
}
