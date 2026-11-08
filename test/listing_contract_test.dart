import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
  const listingResponse = {
    'id': 'listing-42',
    'title': 'Phone',
    'price': 1250,
    'currency': 'AZN',
    'description': 'Good condition',
    'sellerId': 'seller-7',
    'businessId': 'business-3',
    'categoryId': 'electronics',
    'subcategoryId': 'phones',
    'cityId': 'baku',
    'cityName': 'Baku',
    'latitude': 40.4093,
    'longitude': 49.8671,
    'brand': 'Brand',
    'model': 'Model',
    'color': 'Black',
    'storage': '256 GB',
    'simCard': 'Dual SIM',
    'status': 'pending_moderation',
    'createdAt': '2026-10-01T10:00:00Z',
    'updatedAt': '2026-10-02T10:00:00Z',
    'media': [
      {
        'url': 'https://cdn.example.com/photo.jpg',
        'type': 'image',
        'sortOrder': 0,
      },
      {
        'url': 'https://cdn.example.com/video.mp4',
        'type': 'video',
        'sortOrder': 1,
        'thumbnailUrl': 'https://cdn.example.com/thumb.jpg',
      },
    ],
  };

  test('canonical listing parses relationships, status and ordered media', () {
    final listing = Listing.fromJson(listingResponse);

    expect(listing.id, 'listing-42');
    expect(listing.price, 1250);
    expect(listing.currency, 'AZN');
    expect(listing.sellerId, 'seller-7');
    expect(listing.businessId, 'business-3');
    expect(listing.categoryId, 'electronics');
    expect(listing.subcategoryId, 'phones');
    expect(listing.cityId, 'baku');
    expect(listing.status, ListingStatus.pendingModeration);
    expect(listing.createdAt, DateTime.parse('2026-10-01T10:00:00Z'));
    expect(listing.media.map((item) => item.sortOrder), [0, 1]);
    expect(listing.media.last.type, ListingMediaType.video);
    expect(
      listing.media.last.thumbnailUrl,
      'https://cdn.example.com/thumb.jpg',
    );
    expect(Listing.fromJson(listing.toJson()).id, listing.id);
  });

  test('feed item keeps canonical Product identity and video metadata', () {
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
      'ownerAvatarUrl': 'https://cdn.example.com/seller.jpg',
      'products': [
        {
          'id': 'listing-42',
          'title': 'Phone',
          'price': 1250,
          'currency': 'AZN',
          'description': 'Good condition',
          'imageUrls': ['https://cdn.example.com/photo.jpg'],
          'sellerId': 'seller-7',
          'businessId': 'business-3',
          'categoryId': 'electronics',
          'subcategoryId': 'phones',
          'cityId': 'baku',
          'latitude': 40.4093,
          'longitude': 49.8671,
          'brand': 'Brand',
          'model': 'Model',
          'color': 'Black',
          'storage': '256 GB',
          'simCard': 'Dual SIM',
          'status': 'active',
          'createdAt': '2026-10-01T10:00:00Z',
        },
      ],
    });

    expect(item.product?.id, 'listing-42');
    expect(item.product?.price, 1250);
    expect(item.product?.subcategoryId, 'phones');
    expect(item.product?.cityId, 'baku');
    expect(item.product?.brand, 'Brand');
    expect(item.product?.color, 'Black');
    expect(item.product?.latitude, 40.4093);
    expect(item.createdAt, DateTime.parse('2026-10-01T10:00:00Z'));
    expect(item.hlsUrl, 'https://cdn.example.com/video.m3u8');
    expect(item.rawUrl, 'https://cdn.example.com/video.mp4');
    expect(item.thumbnailUrl, 'https://cdn.example.com/thumb.jpg');
    expect(item.ownerId, 'seller-7');
  });

  test('Product keeps brand separate from subcategory identity', () {
    const product = Product(
      id: 'listing-42',
      title: 'Phone',
      price: 1250,
      brand: 'Brand',
      subcategoryId: 'phones',
      cityId: 'baku',
      categoryId: 'electronics',
    );

    expect(product.brand, 'Brand');
    expect(product.subcategoryId, 'phones');
    expect(product.cityId, 'baku');
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

  test('listing parser rejects missing relationship IDs and timestamps', () {
    final missingCity = Map<String, dynamic>.from(listingResponse)
      ..remove('cityId');
    final missingCreatedAt = Map<String, dynamic>.from(listingResponse)
      ..remove('createdAt');

    expect(() => Listing.fromJson(missingCity), throwsStateError);
    expect(() => Listing.fromJson(missingCreatedAt), throwsStateError);
  });

  test(
    'listing status maps known aliases and retains unknown future states',
    () {
      expect(
        ListingStatus.parse('pending-review'),
        ListingStatus.pendingModeration,
      );
      expect(ListingStatus.parse('active'), ListingStatus.active);
      expect(ListingStatus.parse('future_state'), ListingStatus.unknown);
      expect(ListingStatus.pendingModeration.apiValue, 'pending_moderation');
    },
  );
}
