import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/messages/model/conversation_model.dart';
import 'package:vidsell/features/messages/model/notification_item_model.dart';
import 'package:vidsell/models/messaging/conversation.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/social/favorite.dart';
import 'package:vidsell/models/social/review.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';
import 'package:vidsell/models/store/store_statistics.dart';
import 'package:vidsell/models/video/feed_item.dart';
import 'package:vidsell/models/wallet/top_up_intent.dart';
import 'package:vidsell/models/wallet/wallet_balance.dart';
import 'package:vidsell/models/wallet/wallet_transaction.dart';

const _exampleId = '00000000-0000-4000-8000-000000000001';

late Map<String, dynamic> _openApi;

void main() {
  setUpAll(() {
    _openApi =
        jsonDecode(File('docs/openapi.json').readAsStringSync())
            as Map<String, dynamic>;
  });

  test('Product parses an example generated from ProductResponse', () {
    final json = _example('ProductResponse')..['phoneNumber'] = '+15555550123';
    final product = Product.fromJson(json);

    expect(product.id, _exampleId);
    expect(product.title, 'example');
    expect(product.imageUrls, ['https://example.test/image.jpg']);
    expect(product.sellerName, 'example');
    expect(product.sellerPhone, isNull);
  });

  test('FeedItem parses FeedItemResponse and its product items', () {
    final item = FeedItem.fromJson(_example('FeedItemResponse'));

    expect(item.videoId, _exampleId);
    expect(item.ownerName, 'example');
    expect(item.product?.id, _exampleId);
    expect(item.product?.imageUrls, ['example']);
  });

  test('Store and MyStore parse StoreResponse', () {
    final json = _example('StoreResponse');
    final store = Store.fromJson(json);
    final myStore = MyStore.fromJson(json);

    expect(store.id, _exampleId);
    expect(store.name, 'example');
    expect(store.isOpen, isTrue);
    expect(myStore.id, _exampleId);
    expect(myStore.isOpen, isTrue);
  });

  test('StoreStatistics parses StoreStatisticsResponse', () {
    final statistics = StoreStatistics.fromJson(
      _example('StoreStatisticsResponse'),
    );

    expect(statistics.views, 1);
    expect(statistics.calls, 1);
    expect(statistics.messages, 1);
    expect(statistics.listings, 1);
    expect(statistics.followers, 1);
    expect(statistics.range, 'example');
    expect(
      statistics.series.single.date?.toIso8601String(),
      '2026-01-02T00:00:00.000',
    );
  });

  test('Conversation parses ConversationResponse and nested brief objects', () {
    final json = _example('ConversationResponse');
    final conversation = Conversation.fromJson(json);
    final conversationModel = ConversationModel.fromJson(json);

    expect(conversation.otherUser.fullName, 'example');
    expect(conversation.product?.id, _exampleId);
    expect(conversation.lastMessage, 'example');
    expect(conversationModel.participantName, 'example');
    expect(conversationModel.listingId, _exampleId);
    expect(conversationModel.lastMessage, 'example');
    expect(conversationModel.muted, isTrue);
  });

  test('Wallet models parse their response schemas', () {
    final balance = WalletBalance.fromJson(_example('WalletBalanceResponse'));
    final transaction = WalletTransaction.fromJson(
      _example('TransactionResponse'),
    );

    expect(balance.balance, 1.5);
    expect(balance.currency, 'example');
    expect(transaction.id, _exampleId);
    expect(transaction.amount, 1.5);
    expect(transaction.description, 'example');
  });

  test('TopUpIntent parses TopUpIntentResponse', () {
    final intent = TopUpIntent.fromJson(_example('TopUpIntentResponse'));

    expect(intent.id, _exampleId);
    expect(intent.invoiceNumber, 'example');
    expect(intent.createdAt, isNotNull);
    expect(intent.completedAt, isNotNull);
  });

  test('Notification parses NotificationResponse', () {
    final notification = NotificationItemModel.fromJson(
      _example('NotificationResponse'),
    );

    expect(notification.id, _exampleId);
    expect(notification.type, 'MESSAGE');
    expect(notification.body, 'example');
    expect(notification.actorId, _exampleId);
    expect(notification.createdAt, isNotNull);
  });

  test('Review parses ReviewResponse', () {
    final review = Review.fromJson(_example('ReviewResponse'));

    expect(review.id, _exampleId);
    expect(review.authorId, _exampleId);
    expect(review.authorAvatarUrl, 'example');
    expect(review.createdAt, isNotNull);
  });

  test('Favorite parses FavoriteResponse', () {
    final favorite = Favorite.fromJson(_example('FavoriteResponse'));

    expect(favorite.id, _exampleId);
    expect(favorite.title, 'example');
    expect(favorite.sellerId, _exampleId);
    expect(favorite.favoritedAt, isNotNull);
  });
}

Map<String, dynamic> _example(String schemaName) {
  final schemas =
      (_openApi['components'] as Map<String, dynamic>)['schemas']
          as Map<String, dynamic>;
  return Map<String, dynamic>.from(
    _exampleValue(schemas[schemaName] as Map<String, dynamic>) as Map,
  );
}

dynamic _exampleValue(Map<String, dynamic> schema, {String? fieldName}) {
  final reference = schema[r'$ref'];
  if (reference is String) {
    final schemaName = reference.split('/').last;
    final schemas =
        (_openApi['components'] as Map<String, dynamic>)['schemas']
            as Map<String, dynamic>;
    return _exampleValue(Map<String, dynamic>.from(schemas[schemaName] as Map));
  }

  final values = schema['enum'];
  if (values is List && values.isNotEmpty) return values.first;
  if (fieldName == 'imageUrls') {
    return jsonEncode(['https://example.test/image.jpg']);
  }

  return switch (schema['type']) {
    'object' => {
      for (final property
          in (schema['properties'] as Map<String, dynamic>).entries)
        property.key: _exampleValue(
          Map<String, dynamic>.from(property.value as Map),
          fieldName: property.key,
        ),
    },
    'array' => [
      _exampleValue(Map<String, dynamic>.from(schema['items'] as Map)),
    ],
    'string' => switch (schema['format']) {
      'uuid' => _exampleId,
      'date-time' => '2026-01-02T03:04:05Z',
      'date' => '2026-01-02',
      _ => 'example',
    },
    'integer' => 1,
    'number' => 1.5,
    'boolean' => true,
    _ => null,
  };
}
