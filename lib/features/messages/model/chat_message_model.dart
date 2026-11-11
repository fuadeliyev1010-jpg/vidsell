import 'package:vidsell/models/messaging/message.dart';
import 'package:vidsell/core/network/media_url.dart';

export 'package:vidsell/models/messaging/message.dart' show MessageType;

class ChatMessageModel extends Message {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required String text,
    super.senderId = '',
    required super.createdAt,
    required super.isMe,
    super.imageUrl,
    super.isRead,
    super.type,
  }) : super(content: text);

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
    senderId: senderId,
    imageUrl: imageUrl,
    createdAt: createdAt,
    isMe: isMe ?? this.isMe,
    isRead: isRead ?? this.isRead,
    type: type,
  );

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultConversationId,
    String? mediaOrigin,
  }) {
    final id = json['id'] ?? json['messageId'];
    final conversationId = json['conversationId'] ?? defaultConversationId;
    if (id == null || '$id'.isEmpty || conversationId == null) {
      throw const FormatException('Message or conversation ID is missing.');
    }
    final rawImageUrl = json['imageUrl'] ?? json['attachmentUrl'];
    final imageUrl = rawImageUrl is String && mediaOrigin != null
        ? resolveMediaUrl(rawImageUrl, origin: mediaOrigin)
        : rawImageUrl;
    final deleted = json['isDeleted'] == true || json['deletedAt'] != null;
    return ChatMessageModel(
      id: '$id',
      conversationId: '$conversationId',
      text: '${json['content'] ?? json['text'] ?? json['body'] ?? ''}',
      senderId: '${json['senderId'] ?? ''}',
      imageUrl: imageUrl,
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      isMe: json['isMine'] == true || json['isMe'] == true,
      isRead: json['isRead'] == true || json['readAt'] != null,
      type: deleted
          ? MessageType.deleted
          : imageUrl is String && imageUrl.isNotEmpty
          ? MessageType.image
          : MessageType.text,
    );
  }
}
