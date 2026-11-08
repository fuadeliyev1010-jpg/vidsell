import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
  test('Product keeps canonical fields and status', () {
    final product = Product.fromJson({
      'id': 'product-42',
      'title': 'Phone',
      'price': 1250,
      'currency': 'TRY',
      'imageUrls': '["https://cdn.example.com/photo.jpg"]',
      'category': 'ELECTRONICS',
      'subcategory': 'PHONES',
      'city': 'Baku',
      'brand': 'Brand',
      'modelName': 'Model',
      'color': 'Black',
      'latitude': 40.4093,
      'status': 'ACTIVE',
      'createdAt': '2026-10-01T10:00:00Z',
    });

    expect(product.id, 'product-42');
    expect(product.status, ProductStatus.active);
    expect(product.imageUrls, ['https://cdn.example.com/photo.jpg']);
    expect(product.category?.code, 'ELECTRONICS');
    expect(product.subcategory?.code, 'PHONES');
    expect(product.brand, 'Brand');
    expect(product.city, 'Baku');
    expect(product.createdAt, DateTime.parse('2026-10-01T10:00:00Z'));
  });

  test('FeedItem uses its first Product and retains video metadata', () {
    final item = FeedItem.fromJson({
      'videoId': 'video-42',
      'createdAt': '2026-10-01T10:00:00Z',
      'hlsUrl': 'https://cdn.example.com/video.m3u8',
      'rawUrl': 'https://cdn.example.com/video.mp4',
      'thumbnailUrl': 'https://cdn.example.com/thumb.jpg',
      'durationSeconds': 12,
      'contentType': 'RECENT',
      'ownerId': 'seller-7',
      'ownerName': 'Seller',
      'products': [
        {
          'id': 'product-42',
          'title': 'Phone',
          'price': 1250,
          'currency': 'TRY',
          'imageUrls': '["https://cdn.example.com/photo.jpg"]',
          'status': 'ACTIVE',
        },
      ],
    });

    expect(item.product?.id, 'product-42');
    expect(item.product?.price, 1250);
    expect(item.createdAt, DateTime.parse('2026-10-01T10:00:00Z'));
    expect(item.hlsUrl, 'https://cdn.example.com/video.m3u8');
    expect(item.rawUrl, 'https://cdn.example.com/video.mp4');
    expect(item.thumbnailUrl, 'https://cdn.example.com/thumb.jpg');
    expect(item.ownerId, 'seller-7');
  });

  test('video-only feed items keep poster and playback without a Product', () {
    final item = FeedItem.fromJson({
      'videoId': 'video-only',
      'products': [],
      'hlsUrl': 'https://cdn.example.com/video.m3u8',
      'thumbnailUrl': 'https://cdn.example.com/video-thumb.jpg',
    });

    expect(item.product, isNull);
    expect(item.thumbnailUrl, 'https://cdn.example.com/video-thumb.jpg');
    expect(item.videoUrl, 'https://cdn.example.com/video.m3u8');
  });
}
