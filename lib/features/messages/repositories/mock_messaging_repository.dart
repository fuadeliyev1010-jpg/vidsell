import 'package:vidsell/features/messages/model/chat_message_model.dart';
import 'package:vidsell/features/messages/model/conversation_model.dart';
import 'package:vidsell/features/messages/model/notification_item_model.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';

class MockMessagingRepository implements MessagingRepository {
  MockMessagingRepository._();

  static final instance = MockMessagingRepository._();

  final Map<String, ConversationModel> _conversations = {};
  final Map<String, List<ChatMessageModel>> _messages = {};
  final Map<String, NotificationItemModel> _notifications = {};
  int _nextId = 1;

  @override
  Future<List<ConversationModel>> fetchConversations() async {
    final conversations = _conversations.values.toList()
      ..sort((a, b) {
        final bDate = b.updatedAt;
        final aDate = a.updatedAt;
        if (bDate == null) return aDate == null ? 0 : -1;
        if (aDate == null) return 1;
        return bDate.compareTo(aDate);
      });
    return conversations;
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
    for (final conversation in _conversations.values) {
      if (conversation.participantId == participantId &&
          conversation.listingId == listingId) {
        return conversation;
      }
    }

    final id = 'mock-conversation-${_nextId++}';
    final conversation = ConversationModel(
      id: id,
      participantId: participantId,
      participantName: participantName,
      participantAvatar: participantAvatar,
      listingId: listingId,
      listingTitle: listingTitle,
      listingImage: listingImage,
      listingPrice: listingPrice,
      lastMessage: '',
      updatedAt: DateTime.now(),
      unreadCount: 0,
    );
    _conversations[id] = conversation;
    _messages[id] = [];
    return conversation;
  }

  @override
  Future<List<ChatMessageModel>> fetchMessages(String conversationId) async {
    _requireConversation(conversationId);
    return List.unmodifiable(_messages[conversationId]!);
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    final conversation = _requireConversation(conversationId);
    _conversations[conversationId] = _copyConversation(
      conversation,
      unreadCount: 0,
    );
  }

  @override
  Future<ChatMessageModel> sendMessage(
    String conversationId,
    String text,
  ) async {
    final conversation = _requireConversation(conversationId);
    final message = ChatMessageModel(
      id: 'mock-message-${_nextId++}',
      conversationId: conversationId,
      text: text,
      createdAt: DateTime.now(),
      isMe: true,
    );
    _messages[conversationId]!.add(message);
    _conversations[conversationId] = _copyConversation(
      conversation,
      lastMessage: text,
      updatedAt: message.createdAt,
    );
    return message;
  }

  @override
  Future<void> deleteConversations(List<String> conversationIds) async {
    for (final id in conversationIds) {
      _conversations.remove(id);
      _messages.remove(id);
    }
  }

  @override
  Future<void> deleteMessages(
    String conversationId,
    List<String> messageIds,
  ) async {
    final conversation = _requireConversation(conversationId);
    final messages = _messages[conversationId]!;
    messages.removeWhere((message) => messageIds.contains(message.id));
    final latestMessage = messages.isEmpty ? null : messages.last;
    _conversations[conversationId] = _copyConversation(
      conversation,
      lastMessage: latestMessage?.text ?? '',
      updatedAt: latestMessage?.createdAt,
    );
  }

  @override
  Future<void> clearMessages(String conversationId) async {
    final conversation = _requireConversation(conversationId);
    _messages[conversationId]!.clear();
    _conversations[conversationId] = _copyConversation(
      conversation,
      lastMessage: '',
    );
  }

  @override
  Future<List<NotificationItemModel>> fetchNotifications() async =>
      List.unmodifiable(_notifications.values);

  @override
  Future<void> markNotificationRead(String notificationId) async {
    final notification = _notifications[notificationId];
    if (notification == null) {
      throw StateError('Notification $notificationId was not found.');
    }
    _notifications[notificationId] = notification.copyWith(isRead: true);
  }

  @override
  Future<void> markAllNotificationsRead() async {
    for (final entry in _notifications.entries.toList()) {
      _notifications[entry.key] = entry.value.copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.remove(notificationId);
  }

  ConversationModel _requireConversation(String id) {
    final conversation = _conversations[id];
    if (conversation == null) {
      throw StateError('Conversation $id was not found.');
    }
    return conversation;
  }

  ConversationModel _copyConversation(
    ConversationModel conversation, {
    String? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) => ConversationModel(
    id: conversation.id,
    participantId: conversation.participantId,
    participantName: conversation.participantName,
    participantAvatar: conversation.participantAvatar,
    listingId: conversation.listingId,
    listingTitle: conversation.listingTitle,
    listingImage: conversation.listingImage,
    listingPrice: conversation.listingPrice,
    lastMessage: lastMessage ?? conversation.lastMessage,
    updatedAt: updatedAt ?? conversation.updatedAt,
    unreadCount: unreadCount ?? conversation.unreadCount,
  );
}
