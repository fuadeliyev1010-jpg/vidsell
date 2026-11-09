import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/models/common/api_error.dart';
import 'package:vidsell/models/user/user.dart';

class MockApiClient {
  MockApiClient({SessionStore? sessionStore})
    : _sessionStore = sessionStore ?? InMemorySessionStore();

  static const String demoOtp = '123456';
  final Map<String, User> _usersByIdentifier = {};
  final Map<String, String> _otpByIdentifier = {};
  final SessionStore _sessionStore;

  Future<void> sendOtp(String identifier) async {
    final normalized = _normalize(identifier);
    if (normalized.isEmpty) {
      throw const ApiException(
        'Telefon numarası veya e-posta gereklidir.',
        apiError: ApiError(code: 'IDENTIFIER_REQUIRED'),
      );
    }
    _otpByIdentifier[normalized] = demoOtp;
  }

  Future<User?> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    final normalized = _normalize(identifier);
    if (_otpByIdentifier[normalized] != code) {
      throw const ApiException(
        'Doğrulama kodu geçersiz.',
        apiError: ApiError(code: 'INVALID_OTP'),
      );
    }

    _otpByIdentifier.remove(normalized);
    return _usersByIdentifier[normalized];
  }

  Future<AuthSession> register({
    required String identifier,
    required String name,
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    final normalized = _normalize(identifier);
    if (_otpByIdentifier[normalized] != verificationCode) {
      throw const ApiException(
        'Doğrulama kodu geçersiz.',
        apiError: ApiError(code: 'INVALID_OTP'),
      );
    }
    _otpByIdentifier.remove(normalized);
    if (_usersByIdentifier.containsKey(normalized)) {
      throw const ApiException(
        'Bu hesap zaten kayıtlıdır.',
        apiError: ApiError(code: 'ACCOUNT_ALREADY_REGISTERED'),
      );
    }

    final user = User(
      id: 'user-${_usersByIdentifier.length + 1}',
      identifier: normalized,
      name: name,
      email: email,
    );
    _usersByIdentifier[normalized] = user;
    return _createSession(user);
  }

  Future<AuthSession?> restoreSession() => _sessionStore.read();

  Future<void> logout() async {
    await _sessionStore.clear();
  }

  Future<AuthSession> _createSession(User user) async {
    final session = AuthSession(
      accessToken: 'mock-access-token-${user.id}',
      refreshToken: 'mock-refresh-token-${user.id}',
      user: user,
    );
    await _sessionStore.write(session);
    return session;
  }

  String _normalize(String value) => value.trim().toLowerCase();

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final user = _usersByIdentifier[_normalize(identifier)];
    if (user == null) {
      throw const ApiException(
        'Hesap bulunamadı.',
        apiError: ApiError(code: 'ACCOUNT_NOT_FOUND'),
      );
    }
    return _createSession(user);
  }
}
