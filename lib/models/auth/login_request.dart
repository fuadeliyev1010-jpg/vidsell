class LoginRequest {
  const LoginRequest({
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
  });

  final String countryCode;
  final String phoneNumber;
  final String password;

  Map<String, dynamic> toJson() => {
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'password': password,
  };
}
