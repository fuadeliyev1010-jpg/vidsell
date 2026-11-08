import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/home/bloc/home_bloc.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';
import 'package:vidsell/features/home/widgets/home_listing_media.dart';
import 'package:vidsell/features/discover/models/product_listing.dart';
import 'package:vidsell/features/discover/utils/product_listing_home_adapter.dart';

void main() {
  test('mock home repository returns cursor-paginated listings', () async {
    final repository = MockHomeRepository();

    final firstPage = await repository.fetchListings(limit: 5);
    final secondPage = await repository.fetchListings(
      cursor: firstPage.nextCursor,
      limit: 5,
    );

    expect(firstPage.listings, hasLength(5));
    expect(firstPage.hasMore, isTrue);
    expect(secondPage.listings, hasLength(5));
    expect(secondPage.hasMore, isTrue);
    expect(
      firstPage.listings.map((listing) => listing.id),
      isNot(contains(secondPage.listings.first.id)),
    );
  });

  test('missing listing coordinates remain unavailable for map placement', () {
    const listing = ProductListing(
      imagePath: '',
      price: '',
      title: '',
      timeAgo: '',
    );
    final homeListing = HomeListing.fromJson({
      'id': 'listing-default-city',
      'price': 100,
      'currency': 'AZN',
      'sellerId': 'seller-default',
      'categoryId': 'electronics',
      'subcategoryId': 'phones',
      'cityId': 'istanbul',
      'status': 'active',
      'createdAt': '2026-01-01T00:00:00Z',
      'sellerName': 'Seller',
      'sellerHandle': '@seller',
      'title': 'Phone',
      'shareUrl': 'https://vidsell.example/listing/1',
    });

    expect(listing.location, 'İstanbul');
    expect(listing.latitude, isNull);
    expect(listing.longitude, isNull);
    expect(homeListing.city, 'İstanbul');
  });

  test('listing JSON accepts backend media and numeric price fields', () {
    final listing = HomeListing.fromJson({
      'id': 'listing-7',
      'imageUrl': 'https://cdn.example.com/listing-7.jpg',
      'sellerName': 'Seller',
      'sellerHandle': '@seller',
      'sellerAvatar': 'https://cdn.example.com/seller.jpg',
      'price': 1250,
      'currency': 'AZN',
      'title': 'Phone',
      'shareUrl': 'https://vidsell.az/listing/7',
      'sellerId': 'seller-7',
      'categoryId': 'electronics',
      'subcategoryId': 'phones',
      'cityId': 'istanbul',
      'status': 'active',
      'createdAt': '2026-01-01T00:00:00Z',
    });

    expect(listing.imagePath, startsWith('https://'));
    expect(listing.isNetworkMedia, isTrue);
    expect(listing.price, '1250 AZN');
    expect(listing.sellerAvatar, 'https://cdn.example.com/seller.jpg');
  });

  test('listing JSON keeps detail fields and video with the feed item', () {
    final listing = HomeListing.fromJson({
      'id': 'listing-video',
      'imageUrl': 'https://cdn.example.com/listing-poster.jpg',
      'videoUrl': 'https://cdn.example.com/listing-video.mp4',
      'sellerName': 'Seller',
      'sellerHandle': '@seller',
      'price': 1250,
      'currency': 'AZN',
      'title': 'Phone',
      'shareUrl': 'https://vidsell.az/listing/video',
      'sellerId': 'seller-video',
      'categoryId': 'electronics',
      'subcategoryId': 'phones',
      'cityId': 'istanbul',
      'status': 'active',
      'createdAt': '2026-01-01T00:00:00Z',
      'phoneNumber': '+994501234567',
      'description': 'Listing details',
      'city': 'Bakı',
      'brand': 'Apple',
      'model': 'iPhone 16',
      'storage': '128GB',
      'simCard': 'eSIM',
      'condition': 'New',
      'delivery': 'Pickup',
      'listingNumber': 123,
      'viewCount': 42,
      'updatedAt': '2026-01-01T00:00:00Z',
    });

    expect(listing.videoUrl, 'https://cdn.example.com/listing-video.mp4');
    expect(listing.phoneNumber, '+994501234567');
    expect(listing.description, 'Listing details');
    expect(listing.model, 'iPhone 16');
    expect(listing.listingNumber, '123');
    expect(listing.viewCount, 42);
    expect(
      listing
          .copyWith(videoUrl: 'https://cdn.example.com/updated.mp4')
          .videoUrl,
      'https://cdn.example.com/updated.mp4',
    );
  });

  test('video-only listing can be loaded without a poster image', () {
    final listing = HomeListing.fromJson({
      'id': 'video-only',
      'price': 100,
      'currency': 'AZN',
      'sellerId': 'seller-video',
      'categoryId': 'electronics',
      'subcategoryId': 'phones',
      'cityId': 'istanbul',
      'status': 'active',
      'createdAt': '2026-01-01T00:00:00Z',
      'video_url': 'https://cdn.example.com/video-only.mp4',
    });

    expect(listing.imagePath, isEmpty);
    expect(listing.videoUrl, 'https://cdn.example.com/video-only.mp4');
  });

  testWidgets('home listing media does not show image when video URL exists', (
    tester,
  ) async {
    const listing = HomeListing(
      id: 'video-only',
      sellerName: 'Seller',
      sellerHandle: '@seller',
      price: '100 AZN',
      title: 'Video listing',
      shareLink: '',
      videoUrl: 'https://cdn.example.com/video.mp4',
      imagePath: 'assets/images/vidsell_logo.png',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeListingMedia(listing: listing, playing: false),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('home listing media loads bundled video assets', (tester) async {
    const listing = HomeListing(
      id: 'bundled-video',
      sellerName: 'Seller',
      sellerHandle: '@seller',
      price: '100 AZN',
      title: 'Video listing',
      shareLink: '',
      videoUrl: 'assets/images/mock_listing.mp4',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeListingMedia(listing: listing, playing: false),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Discover products convert into the shared details model', () {
    final listing = toHomeListing(
      const ProductListing(
        id: 'discover-1',
        imagePath: 'poster.jpg',
        videoUrl: 'https://cdn.example.com/discover.mp4',
        price: '100 AZN',
        title: 'Product',
        timeAgo: '1 hour',
        brand: 'Brand',
        location: 'Bakı',
        phoneNumber: '+994501234567',
        sellerName: 'Seller',
        sellerId: 'seller-1',
        sellerAvatar: 'https://cdn.example.com/seller.jpg',
      ),
    );

    expect(listing.id, 'discover-1');
    expect(listing.videoUrl, 'https://cdn.example.com/discover.mp4');
    expect(listing.phoneNumber, '+994501234567');
    expect(listing.city, 'Bakı');
    expect(listing.sellerName, 'Seller');
    expect(listing.sellerId, 'seller-1');
    expect(listing.sellerAvatar, 'https://cdn.example.com/seller.jpg');
  });

  test('home bloc loads and appends the next page', () async {
    final bloc = HomeBloc(repository: MockHomeRepository());
    addTearDown(bloc.close);

    final firstStateFuture = bloc.stream.firstWhere(
      (state) => state.status == HomeStatus.success && state.nextCursor != null,
    );
    bloc.add(const HomeListingsRequested());
    final firstState = await firstStateFuture;
    expect(firstState.listings, hasLength(5));

    final secondStateFuture = bloc.stream.firstWhere(
      (state) =>
          state.status == HomeStatus.success && state.listings.length == 10,
    );
    bloc.add(const HomeMoreListingsRequested());
    final secondState = await secondStateFuture;
    expect(secondState.listings, hasLength(10));
  });

  test(
    'nearby home feed sorts listings by distance from GPS location',
    () async {
      final bloc = HomeBloc(repository: MockHomeRepository());
      addTearDown(bloc.close);

      final stateFuture = bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc.add(
        const HomeListingsRequested(
          refresh: true,
          query: HomeFeedQuery(latitude: 41.0082, longitude: 28.9784),
        ),
      );

      final state = await stateFuture;
      expect(state.listings.first.id, 'listing-1');
      expect(state.listings, hasLength(16));
    },
  );

  test('following home feed only loads followed sellers', () async {
    final bloc = HomeBloc(repository: MockHomeRepository());
    addTearDown(bloc.close);

    final stateFuture = bloc.stream.firstWhere(
      (state) => state.status == HomeStatus.success,
    );
    bloc.add(
      const HomeListingsRequested(
        refresh: true,
        query: HomeFeedQuery(sellerIds: ['techstore-1']),
      ),
    );

    final state = await stateFuture;
    expect(state.listings.map((listing) => listing.id), {
      'listing-1',
      'listing-4',
    });
    expect(state.nextCursor, isNull);
  });

  test('For You returns different videos from liked categories', () async {
    final bloc = HomeBloc(repository: MockHomeRepository());
    addTearDown(bloc.close);

    final stateFuture = bloc.stream.firstWhere(
      (state) => state.status == HomeStatus.success,
    );
    bloc.add(
      const HomeListingsRequested(
        refresh: true,
        query: HomeFeedQuery(categoryIds: ['vehicles']),
      ),
    );

    final state = await stateFuture;
    expect(state.listings, isNotEmpty);
    expect(
      state.listings.every((listing) => listing.categoryId == 'vehicles'),
      isTrue,
    );
    expect(
      state.listings.map((listing) => listing.id),
      isNot(contains('listing-1')),
    );
  });

  test(
    'mock video products reuse video URL across Turkish locations',
    () async {
      final repository = MockHomeRepository();
      final page = await repository.fetchListings(limit: 50);

      expect(page.listings.length, greaterThan(10));
      expect(
        page.listings.map((listing) => listing.videoUrl).toSet(),
        hasLength(1),
      );
      expect(
        page.listings.map((listing) => listing.cityId).toSet(),
        containsAll(['istanbul', 'ankara', 'izmir', 'antalya', 'bursa']),
      );
      expect(
        page.listings.map((listing) => listing.categoryId).toSet().length,
        greaterThan(1),
      );
    },
  );
}
