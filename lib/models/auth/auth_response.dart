import '../user/user.dart';
import '../../features/auth/models/auth_token.dart';

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final User user;

  factory AuthResponse.fromJson(
    Map<String, dynamic> json, {
    String? mediaOrigin,
  }) => AuthResponse(
    accessToken: normalizeAuthToken(json['accessToken']),
    refreshToken: normalizeAuthToken(json['refreshToken']),
    tokenType: json['tokenType'] is String
        ? (json['tokenType'] as String).trim()
        : 'Bearer',
    user: User.fromJson(_map(json['user']), mediaOrigin: mediaOrigin),
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'user': user.toJson(),
  };

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};
}
