import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/models/auth/login_request.dart';
import 'package:vidsell/models/auth/register_request.dart';
import 'package:vidsell/models/auth/reset_password_request.dart';
import 'package:vidsell/models/auth/reset_token_response.dart';
import 'package:vidsell/models/auth/send_otp_request.dart';
import 'package:vidsell/models/auth/verify_otp_request.dart';

abstract interface class AuthRepository {
  Future<void> sendOtp(SendOtpRequest request);

  Future<ResetTokenResponse> verifyOtp(VerifyOtpRequest request);

  Future<AuthSession> register(RegisterRequest request);

  Future<AuthSession> login(LoginRequest request);

  Future<void> requestPasswordReset(SendOtpRequest request);

  Future<void> resetPassword(ResetPasswordRequest request);

  Future<AuthSession?> restoreSession();

  Future<void> logout();

  /// Broadcast stream that emits when authentication is invalidated due to token expiration.
  Stream<void> get onSessionExpired;
}
