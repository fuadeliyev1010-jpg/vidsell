class StartConversationRequest {
  const StartConversationRequest({
    required this.recipientId,
    this.productId,
    required this.content,
  });

  final String recipientId;
  final String? productId;
  final String content;

  Map<String, dynamic> toJson() => {
    'recipientId': recipientId,
    if (productId != null) 'productId': productId,
    'content': content,
  };
}
