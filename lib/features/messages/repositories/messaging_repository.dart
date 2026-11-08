import 'package:vidsell/features/messages/model/chat_message_model.dart';
import 'package:vidsell/features/messages/model/conversation_model.dart';
import 'package:vidsell/features/messages/model/notification_item_model.dart';

abstract interface class MessagingRepository {
  Future<List<ConversationModel>> fetchConversations();

  Future<ConversationModel> getOrCreateConversation({
    required String participantId,
    required String? listingId,
    required String participantName,
    String? participantAvatar,
    String? listingTitle,
    String? listingImage,
    String? listingPrice,
  });

  Future<List<ChatMessageModel>> fetchMessages(String conversationId);

  Future<void> markConversationRead(String conversationId);

  Future<ChatMessageModel> sendMessage(String conversationId, String text);

  Future<void> deleteConversations(List<String> conversationIds);

  Future<void> deleteMessages(String conversationId, List<String> messageIds);

  Future<void> clearMessages(String conversationId);

  Future<List<NotificationItemModel>> fetchNotifications();

  Future<void> markNotificationRead(String notificationId);

  Future<void> markAllNotificationsRead();

  Future<void> deleteNotification(String notificationId);
}
