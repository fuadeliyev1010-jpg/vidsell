import '../enums/gender.dart';
import '../enums/role.dart';

class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
    this.email = '',
    required this.gender,
    required this.termsAccepted,
    required this.role,
    required this.verificationCode,
  });

  final String fullName;
  final String countryCode;
  final String phoneNumber;
  final String password;
  final String email;
  final Gender gender;
  final bool termsAccepted;
  final Role role;
  final String verificationCode;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'password': password,
    if (email.isNotEmpty) 'email': email,
    'gender': gender.code,
    'termsAccepted': termsAccepted,
    'role': role.code,
    'verificationCode': verificationCode,
  };
}
