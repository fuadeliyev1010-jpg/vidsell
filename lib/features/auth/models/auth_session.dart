import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:vidsell/models/auth/auth_response.dart';
import 'package:vidsell/models/user/user.dart';
import 'package:vidsell/features/auth/models/auth_token.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.tokenType = 'Bearer',
    this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final User user;
  final DateTime? expiresAt;

  factory AuthSession.fromAuthResponse(AuthResponse response) => AuthSession(
    accessToken: response.accessToken,
    refreshToken: response.refreshToken,
    tokenType: response.tokenType,
    user: response.user,
    expiresAt: tryParseJwtExpiry(response.accessToken),
  );

  /// Returns true if the token has explicitly expired (via [expiresAt] or parsed JWT `exp`).
  bool get isExpired {
    final expiry = expiresAt ?? tryParseJwtExpiry(accessToken);
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  /// Attempts to extract the expiration timestamp from a standard JWT access token.
  static DateTime? tryParseJwtExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final map = jsonDecode(payload);
      if (map is Map<String, dynamic> && map['exp'] != null) {
        final exp = map['exp'];
        if (exp is int) {
          return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        }
      }
    } catch (_) {}
    return null;
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final rawExpiresAt = json['expiresAt'];
    final accessToken = normalizeAuthToken(
      json['accessToken'] ?? json['token'],
    );
    return AuthSession(
      accessToken: accessToken,
      refreshToken: normalizeAuthToken(json['refreshToken']),
      tokenType: json['tokenType'] is String
          ? (json['tokenType'] as String).trim()
          : 'Bearer',
      user: User.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : const {},
      ),
      expiresAt: rawExpiresAt != null
          ? DateTime.tryParse(rawExpiresAt.toString())
          : tryParseJwtExpiry(accessToken),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'user': user.toJson(),
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
  };

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    User? user,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    tokenType,
    user,
    expiresAt,
  ];
}
