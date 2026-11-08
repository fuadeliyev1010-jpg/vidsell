enum MessageType { text, image, deleted }

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.isMe = false,
    this.isRead = false,
    this.type = MessageType.text,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime? readAt;
  final DateTime? createdAt;
  final String? imageUrl;
  final bool isMe;
  final bool isRead;
  final MessageType type;

  String get text => content;
}
