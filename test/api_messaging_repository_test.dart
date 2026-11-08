import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/messages/repositories/api_messaging_repository.dart';

void main() {
  test(
    'loads conversations and messages using stable IDs and listing context',
    () async {
      final adapter = _MessagingResponseAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      final repository = ApiMessagingRepository(client);
      final conversations = await repository.fetchConversations();
      final messages = await repository.fetchMessages('conversation-1');

      expect(conversations.single.id, 'conversation-1');
      expect(conversations.single.listingId, 'listing-1');
      expect(conversations.single.listingTitle, 'Camera');
      expect(conversations.single.unreadCount, 2);
      expect(messages.single.id, 'message-1');
      expect(messages.single.conversationId, 'conversation-1');
      expect(messages.single.text, 'Is it available?');
      expect(adapter.requests.map((request) => request.path), [
        '/me/conversations',
        '/me/conversations/conversation-1/messages',
      ]);
    },
  );

  test(
    'creates conversations, sends messages, and persists notification reads',
    () async {
      final adapter = _MessagingResponseAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });
      final repository = ApiMessagingRepository(client);

      final conversation = await repository.getOrCreateConversation(
        participantId: 'seller-1',
        listingId: 'listing-1',
        participantName: 'Seller',
        listingTitle: 'Camera',
      );
      final message = await repository.sendMessage(conversation.id, 'Hello');
      await repository.markConversationRead(conversation.id);
      final notifications = await repository.fetchNotifications();
      await repository.markNotificationRead(notifications.single.id);
      await repository.markAllNotificationsRead();
      await repository.deleteMessages(conversation.id, [message.id]);
      await repository.clearMessages(conversation.id);
      await repository.deleteConversations([conversation.id]);
      await repository.deleteNotification(notifications.single.id);

      expect(conversation.id, 'conversation-2');
      expect(message.conversationId, 'conversation-2');
      expect(message.isMe, isTrue);
      expect(notifications.single.id, 'notification-1');
      expect(adapter.requests[0].data, {
        'participantId': 'seller-1',
        'listingId': 'listing-1',
      });
      expect(adapter.requests[1].data, {'text': 'Hello'});
      expect(adapter.requests[2].path, '/me/conversations/conversation-2/read');
      expect(adapter.requests[3].path, '/me/notifications');
      expect(adapter.requests[4].path, '/me/notifications/notification-1');
      expect(adapter.requests[5].path, '/me/notifications/read');
      expect(adapter.requests.skip(6).map((request) => request.path), [
        '/me/conversations/conversation-2/messages/message-2',
        '/me/conversations/conversation-2/messages',
        '/me/conversations/conversation-2',
        '/me/notifications/notification-1',
      ]);
    },
  );
}

class _MessagingResponseAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final dynamic body;
    if (options.method == 'GET' && options.path == '/me/conversations') {
      body = {
        'items': [
          {
            'id': 'conversation-1',
            'participant': {'id': 'seller-1', 'name': 'Seller'},
            'listing': {'id': 'listing-1', 'title': 'Camera'},
            'lastMessage': {'text': 'Is it available?'},
            'updatedAt': '2026-10-30T12:00:00Z',
            'unreadCount': 2,
          },
        ],
      };
    } else if (options.method == 'GET' &&
        options.path.endsWith('/conversation-1/messages')) {
      body = {
        'items': [
          {
            'id': 'message-1',
            'text': 'Is it available?',
            'createdAt': '2026-10-30T12:00:00Z',
          },
        ],
      };
    } else if (options.method == 'POST' &&
        options.path == '/me/conversations') {
      body = {
        'id': 'conversation-2',
        'participantId': 'seller-1',
        'participantName': 'Seller',
        'listingId': 'listing-1',
        'listingTitle': 'Camera',
      };
    } else if (options.method == 'POST' &&
        options.path.endsWith('/conversation-2/messages')) {
      body = {
        'id': 'message-2',
        'text': 'Hello',
        'createdAt': '2026-10-30T12:01:00Z',
      };
    } else if (options.method == 'GET' && options.path == '/me/notifications') {
      body = {
        'items': [
          {
            'id': 'notification-1',
            'title': 'New message',
            'description': 'You received a message',
            'createdAt': '2026-10-30T12:00:00Z',
            'isRead': false,
          },
        ],
      };
    } else {
      body = {};
    }

    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
