import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/messages/model/chat_message_model.dart';
import 'package:vidsell/features/messages/model/conversation_model.dart';
import 'package:vidsell/features/messages/model/notification_item_model.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';

class ApiMessagingRepository implements MessagingRepository {
  ApiMessagingRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ConversationModel>> fetchConversations() async {
    final data = await _client.get('/conversations');
    return parsePage(
      data,
      ConversationModel.fromJson,
      itemKey: 'conversations',
    ).items;
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String participantId,
    required String? listingId,
    required String participantName,
    String? participantAvatar,
    String? listingTitle,
    String? listingImage,
    String? listingPrice,
  }) async {
    final data = await _client.post(
      '/conversations',
      data: {
        'recipientId': participantId,
        'productId': ?listingId,
        'content': '',
      },
    );
    return ConversationModel.fromJson(_object(data, 'conversation'));
  }

  @override
  Future<List<ChatMessageModel>> fetchMessages(String conversationId) async {
    final data = await _client.get('/conversations/$conversationId/messages');
    return parsePage(
      data,
      (item) => ChatMessageModel.fromJson(
        item,
        defaultConversationId: conversationId,
      ),
      itemKey: 'messages',
    ).items;
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    await _client.patch('/conversations/$conversationId/read');
  }

  @override
  Future<ChatMessageModel> sendMessage(
    String conversationId,
    String text,
  ) async {
    final data = await _client.post(
      '/conversations/$conversationId/messages',
      data: {'content': text},
    );
    return ChatMessageModel.fromJson(
      _object(data, 'message'),
      defaultConversationId: conversationId,
    ).copyWith(isMe: true);
  }

  @override
  Future<void> deleteConversations(List<String> conversationIds) async {
    for (final id in conversationIds) {
      await _client.delete('/conversations/$id');
    }
  }

  @override
  Future<void> deleteMessages(
    String conversationId,
    List<String> messageIds,
  ) async => throw UnsupportedError(
    'Deleting individual messages is not available in the backend API.',
  );

  @override
  Future<void> clearMessages(String conversationId) async =>
      throw UnsupportedError(
        'Clearing messages is not available in the backend API.',
      );

  @override
  Future<List<NotificationItemModel>> fetchNotifications() async {
    final data = await _client.get('/notifications');
    return parsePage(
      data,
      NotificationItemModel.fromJson,
      itemKey: 'notifications',
    ).items;
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await _client.patch('/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await _client.patch('/notifications/read-all');
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _client.delete('/notifications/$notificationId');
  }

  Map<String, dynamic> _object(dynamic data, String name) {
    final value = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;
    if (value is Map<String, dynamic> && value[name] is Map<String, dynamic>) {
      return value[name] as Map<String, dynamic>;
    }
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Invalid $name response.');
  }
}
