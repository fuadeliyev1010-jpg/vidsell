class MuteResponse {
  const MuteResponse({required this.conversationId, required this.muted});

  final String conversationId;
  final bool muted;

  factory MuteResponse.fromJson(Map<String, dynamic> json) => MuteResponse(
    conversationId: '${json['conversationId'] ?? ''}',
    muted: json['muted'] == true,
  );
}
