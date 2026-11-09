class ApiError {
  const ApiError({
    this.status,
    this.error,
    this.code,
    this.messageKey,
    this.details,
  });

  final int? status;
  final String? error;
  final String? code;
  final String? messageKey;
  final List<dynamic>? details;

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
    status: _int(json['status']),
    error: json['error'] is String ? json['error'] as String : null,
    code: json['code'] is String ? json['code'] as String : null,
    messageKey: json['messageKey'] is String
        ? json['messageKey'] as String
        : null,
    details: _details(json['details']),
  );

  factory ApiError.fromResponse(
    Object? body, {
    int? status,
    String? fallbackCode,
    String? fallbackMessageKey,
  }) {
    final map = body is Map ? Map<String, dynamic>.from(body) : const {};
    final nested = map['error'] is Map
        ? Map<String, dynamic>.from(map['error'] as Map)
        : const <String, dynamic>{};
    final source = {...nested, ...map};
    final errorMessage = source['error'] is String
        ? source['error'] as String
        : nested['error'] is String
        ? nested['error'] as String
        : source['message'] is String
        ? source['message'] as String
        : null;
    return ApiError(
      status: _int(source['status']) ?? status,
      error: errorMessage,
      code: source['code'] as String? ?? fallbackCode,
      messageKey: source['messageKey'] as String? ?? fallbackMessageKey,
      details: _details(source['details'] ?? source['errors']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status,
    if (error != null) 'error': error,
    if (code != null) 'code': code,
    if (messageKey != null) 'messageKey': messageKey,
    if (details != null) 'details': details,
  };

  static List<dynamic>? _details(Object? value) => value is List ? value : null;

  static int? _int(dynamic value) =>
      value is int ? value : int.tryParse('$value');
}
