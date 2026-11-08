import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/models/product_listing.dart';
import 'package:vidsell/features/discover/utils/product_listing_home_adapter.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/home/models/listing_detail.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';

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

  test(
    'feed, detail and cabinet models preserve canonical listing identity',
    () {
      final listing = Listing.fromJson(listingResponse);
      final homeListing = HomeListing.fromJson(listingResponse);
      final detail = ListingDetail.fromListing(listing);

      expect(homeListing.id, listing.id);
      expect(homeListing.priceAmount, listing.price);
      expect(homeListing.subcategoryId, listing.subcategoryId);
      expect(homeListing.cityId, listing.cityId);
      expect(homeListing.status, listing.status);
      expect(homeListing.color, listing.color);
      expect(homeListing.storage, listing.storage);
      expect(homeListing.simCard, listing.simCard);
      expect(homeListing.latitude, listing.latitude);
      expect(homeListing.longitude, listing.longitude);
      expect(detail.id, listing.id);
      expect(detail.color, listing.color);
      expect(detail.storage, listing.storage);
      expect(detail.simCard, listing.simCard);
      expect(detail.mediaUrls, listing.media.map((item) => item.url).toList());
      final mapListing = toProductListing(homeListing);
      expect(mapListing.id, listing.id);
      expect(mapListing.latitude, listing.latitude);
      expect(mapListing.longitude, listing.longitude);
    },
  );

  test('discover display listing does not mislabel brand as subcategory', () {
    final homeListing = toHomeListing(
      const ProductListing(
        id: 'listing-42',
        imagePath: 'photo.jpg',
        price: '1250 AZN',
        title: 'Phone',
        timeAgo: '1 hour',
        brand: 'Brand',
        subcategoryId: 'phones',
        cityId: 'baku',
        categoryId: 'electronics',
        priceValue: 1250,
      ),
    );

    expect(homeListing.brand, 'Brand');
    expect(homeListing.subcategoryName, isEmpty);
    expect(homeListing.subcategoryId, 'phones');
    expect(homeListing.cityId, 'baku');
  });

  test('video-only listings use their thumbnail as the card image', () {
    final videoOnlyResponse = Map<String, dynamic>.from(listingResponse)
      ..['media'] = [
        {
          'url': 'https://cdn.example.com/video.mp4',
          'type': 'video',
          'sortOrder': 0,
          'thumbnailUrl': 'https://cdn.example.com/video-thumb.jpg',
        },
      ];

    expect(
      HomeListing.fromJson(videoOnlyResponse).imagePath,
      'https://cdn.example.com/video-thumb.jpg',
    );
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
