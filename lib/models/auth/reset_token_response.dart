class ResetTokenResponse {
  const ResetTokenResponse({required this.resetToken});

  final String resetToken;

  factory ResetTokenResponse.fromJson(Map<String, dynamic> json) =>
      ResetTokenResponse(resetToken: '${json['resetToken'] ?? ''}');

  Map<String, dynamic> toJson() => {'resetToken': resetToken};
}
