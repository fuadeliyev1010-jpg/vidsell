import '../enums/report_reason.dart';

class ReportRequest {
  const ReportRequest({required this.reason, this.description});

  final ReportReason reason;
  final String? description;

  Map<String, dynamic> toJson() => {
    'reason': reason.code,
    if (description != null) 'description': description,
  };
}
