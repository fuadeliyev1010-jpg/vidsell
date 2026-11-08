import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/models/common/api_error.dart';
import 'package:vidsell/models/common/page_response.dart';
import 'package:vidsell/models/enums/feed_content_type.dart';
import 'package:vidsell/models/enums/feed_section.dart';
import 'package:vidsell/models/enums/notification_type.dart';
import 'package:vidsell/models/enums/payment_method.dart';
import 'package:vidsell/models/enums/product_category.dart';
import 'package:vidsell/models/enums/product_condition.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/enums/product_subcategory.dart';
import 'package:vidsell/models/enums/top_up_status.dart';
import 'package:vidsell/models/messaging/conversation.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/product/product_request.dart';
import 'package:vidsell/models/store/store_statistics.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
  test(
    'Product response imageUrls string decodes and requests send an array',
    () {
      final product = Product.fromJson({
        'id': 'p1',
        'title': 'Phone',
        'price': 10,
        'imageUrls': '["a.jpg","b.jpg"]',
      });
      expect(product.imageUrls, ['a.jpg', 'b.jpg']);
      expect(
        const ProductRequest(
          title: 'Phone',
          price: 10,
          category: ProductCategory.electronics,
          subcategory: ProductSubcategory.phones,
          condition: ProductCondition.used,
          brand: 'Brand',
          modelName: 'Model',
          city: 'Baku',
          description: 'Description',
          imageUrls: ['a.jpg'],
        ).toJson(),
        {
          'title': 'Phone',
          'description': 'Description',
          'price': 10,
          'currency': 'TRY',
          'category': 'ELECTRONICS',
          'subcategory': 'PHONES',
          'brand': 'Brand',
          'modelName': 'Model',
          'city': 'Baku',
          'condition': 'USED',
          'imageUrls': ['a.jpg'],
        },
      );
    },
  );

  test('Conversation parses muted user and optional product', () {
    final conversation = Conversation.fromJson({
      'id': 'c1',
      'otherUser': {'id': 'u1', 'fullName': 'User'},
      'product': null,
      'unreadCount': 2,
      'muted': true,
    });
    expect(conversation.otherUser.id, 'u1');
    expect(conversation.product, isNull);
    expect(conversation.unreadCount, 2);
    expect(conversation.muted, isTrue);
  });

  test('FeedItem keeps video content type separate from product payload', () {
    final item = FeedItem.fromJson({
      'videoId': 'v1',
      'contentType': 'RECENT',
      'product': {'id': 'p1', 'title': 'Phone', 'price': 10},
    });
    expect(item.contentType, FeedContentType.recent);
    expect(item.product?.id, 'p1');
  });

  test('PageResponse preserves zero-based response page', () {
    final page = PageResponse.fromJson({
      'items': [
        {'id': 'p1', 'title': 'Phone', 'price': 10},
      ],
      'page': 0,
      'size': 20,
      'totalElements': 1,
      'totalPages': 1,
      'last': true,
    }, Product.fromJson);
    expect(page.page, 0);
  });

  test('ApiError parses machine-readable fields and details', () {
    final error = ApiError.fromJson({
      'status': 400,
      'error': 'Bad Request',
      'code': 'ERROR_INVALID',
      'messageKey': 'errors.invalid',
      'details': ['title'],
    });
    expect(error.status, 400);
    expect(error.code, 'ERROR_INVALID');
    expect(error.messageKey, 'errors.invalid');
    expect(error.details, ['title']);
  });

  test('all newly introduced enum parsers have unknown fallbacks', () {
    expect(ProductStatus.fromCode('future'), ProductStatus.unknown);
    expect(NotificationType.fromCode('future'), NotificationType.unknown);
    expect(PaymentMethod.fromCode('CARD'), PaymentMethod.card);
    expect(PaymentMethod.fromCode('BANK_TRANSFER'), PaymentMethod.bankTransfer);
    expect(PaymentMethod.fromCode('future').code, 'future');
    expect(TopUpStatus.fromCode('future'), TopUpStatus.unknown);
    expect(TopUpStatus.fromCode('future').code, 'future');
    expect(TopUpStatus.fromCode('EXPIRED'), TopUpStatus.expired);
    for (final code in [
      'MOTORCYCLES',
      'BICYCLES',
      'SPARE_PARTS',
      'APARTMENTS',
      'HOUSES',
      'LANDS',
      'COMMERCIAL',
      'REFRIGERATORS',
      'WASHING_MACHINES',
      'AIR_CONDITIONERS',
      'KITCHEN_APPLIANCES',
      'WEDDING',
      'CEREMONY',
      'NATIONAL_CLOTHING',
      'PERFUME',
      'SKINCARE',
      'MAKEUP',
      'HAIRCARE',
    ]) {
      expect(ProductSubcategory.fromCode(code).isUnknown, isFalse);
    }
    expect(ProductSubcategory.fromCode('future'), ProductSubcategory.unknown);
    expect(ProductSubcategory.fromCode('future').code, 'future');
    final product = Product.fromJson({
      'id': 'p1',
      'title': 'Phone',
      'price': 10,
      'subcategory': 'future',
    });
    expect(product.subcategory, ProductSubcategory.unknown);
    expect(product.subcategory!.code, 'future');
    expect(product.toJson()['subcategory'], 'future');
    expect(FeedSection.fromCode('future').code, 'UNKNOWN');
  });

  test('StoreStatistics parses the contract and tolerates unknown fields', () {
    final statistics = StoreStatistics.fromJson({
      'views': '12',
      'calls': 3,
      'messages': 4,
      'listings': 5,
      'followers': 6,
      'range': '7d',
      'series': [
        {'date': '2026-01-02', 'calls': 1, 'messages': 2},
      ],
      'unexpected': {'nested': true},
    });

    expect(statistics.views, 12);
    expect(statistics.calls, 3);
    expect(statistics.messages, 4);
    expect(statistics.listings, 5);
    expect(statistics.followers, 6);
    expect(statistics.range, '7d');
    expect(statistics.series.single.calls, 1);
    expect(statistics.series.single.messages, 2);
    expect(
      statistics.series.single.date?.toIso8601String(),
      '2026-01-02T00:00:00.000',
    );
  });
}
