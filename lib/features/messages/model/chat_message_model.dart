import 'package:vidsell/models/messaging/message.dart';

export 'package:vidsell/models/messaging/message.dart' show MessageType;

class ChatMessageModel extends Message {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required String text,
    required super.createdAt,
    required super.isMe,
    super.imageUrl,
    super.isRead,
    super.type,
  }) : super(content: text, senderId: '');

  String get time {
    final date = createdAt;
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  ChatMessageModel copyWith({bool? isMe, bool? isRead}) => ChatMessageModel(
    id: id,
    conversationId: conversationId,
    text: text,
    imageUrl: imageUrl,
    createdAt: createdAt,
    isMe: isMe ?? this.isMe,
    isRead: isRead ?? this.isRead,
    type: type,
  );

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultConversationId,
  }) {
    final id = json['id'] ?? json['messageId'];
    final conversationId = json['conversationId'] ?? defaultConversationId;
    if (id == null || '$id'.isEmpty || conversationId == null) {
      throw const FormatException('Message or conversation ID is missing.');
    }
    final imageUrl = json['imageUrl'] ?? json['attachmentUrl'];
    final deleted = json['isDeleted'] == true || json['deletedAt'] != null;
    return ChatMessageModel(
      id: '$id',
      conversationId: '$conversationId',
      text: '${json['text'] ?? json['body'] ?? ''}',
      imageUrl: imageUrl is String ? imageUrl : null,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      isMe: json['isMine'] == true || json['isMe'] == true,
      isRead: json['isRead'] == true,
      type: deleted
          ? MessageType.deleted
          : imageUrl is String && imageUrl.isNotEmpty
          ? MessageType.image
          : MessageType.text,
    );
  }
}
