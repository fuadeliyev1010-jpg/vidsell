import 'package:vidsell/models/common/api_error.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.apiError});

  final String message;
  final int? statusCode;
  final ApiError? apiError;
  String? get code => apiError?.code;

  @override
  String toString() => message;
}
