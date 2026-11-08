class VerifyOtpRequest {
  const VerifyOtpRequest({
    required this.countryCode,
    required this.phoneNumber,
    required this.code,
  });

  final String countryCode;
  final String phoneNumber;
  final String code;

  Map<String, dynamic> toJson() => {
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'code': code,
  };
}
