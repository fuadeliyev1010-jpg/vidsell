class SendOtpRequest {
  const SendOtpRequest({required this.countryCode, required this.phoneNumber});

  final String countryCode;
  final String phoneNumber;

  Map<String, dynamic> toJson() => {
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
  };
}
