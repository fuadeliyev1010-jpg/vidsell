import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/home/bloc/home_bloc.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';
import 'package:vidsell/features/home/widgets/home_listing_media.dart';
import 'package:vidsell/core/adapters/product_legacy_adapter.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
  test('mock home repository returns page-indexed listings', () async {
    final repository = MockHomeRepository();

    final firstPage = await repository.fetchListings(page: 1, size: 5);
    final secondPage = await repository.fetchListings(
      page: 2,
      size: 5,
    );

    expect(firstPage.page, 0);
    expect(secondPage.page, 1);
    expect(firstPage.listings, hasLength(5));
    expect(firstPage.hasMore, isTrue);
    expect(secondPage.listings, hasLength(5));
    expect(secondPage.hasMore, isTrue);
    expect(
      firstPage.listings.map((listing) => listing.id),
      isNot(contains(secondPage.listings.first.id)),
    );
  });

  test('mock repository builds feed items with canonical products', () async {
    final page = await MockHomeRepository().fetchListings(size: 1);
    final item = page.items.single;

    expect(item.products, hasLength(1));
    expect(item.product?.id, 'listing-1');
    expect(item.createdAt, isNotNull);
    expect(item.hlsUrl, 'assets/images/mock_listing.mp4');
    expect(item.thumbnailUrl, 'assets/images/mock_listing_thumb.jpg');
    expect(item.ownerName, 'TechStore');
  });

  test('missing product coordinates remain unavailable for map placement', () {
    const product = Product(id: 'without-coordinates', price: 100, title: '');
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

    expect(product.city, isNull);
    expect(product.latitude, isNull);
    expect(product.longitude, isNull);
    expect(homeListing.city, 'İstanbul');
    expect(homeListing.currency, 'AZN');

    const listingWithFallbackCurrency = HomeListing(
      id: 'listing-default-currency',
      sellerName: 'Seller',
      sellerHandle: '@seller',
      price: '100',
      title: 'Phone',
      shareLink: '',
    );
    expect(listingWithFallbackCurrency.currency, 'TRY');
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
    expect(listing.price, '1250 ₼');
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

  testWidgets('inactive home video shows its poster without initializing', (
    tester,
  ) async {
    const listing = FeedItem(
      videoId: 'video-only',
      hlsUrl: 'https://cdn.example.com/video.mp4',
      thumbnailUrl: 'assets/images/vidsell_logo.png',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeFeedMedia(listing: listing, playing: false),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('home listing media loads bundled video assets', (tester) async {
    const listing = FeedItem(
      videoId: 'bundled-video',
      hlsUrl: 'assets/images/mock_listing.mp4',
      thumbnailUrl: 'assets/images/mock_listing_thumb.jpg',
    );

    Widget media({required bool playing}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: HomeFeedMedia(listing: listing, playing: playing),
      ),
    );

    await tester.pumpWidget(media(playing: false));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpWidget(media(playing: true));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Product converts into the shared home listing model', () {
    final listing = ProductLegacyAdapter.toHomeListing(
      const Product(
        id: 'discover-1',
        imageUrls: ['poster.jpg'],
        price: 100,
        currency: 'AZN',
        title: 'Product',
        brand: 'Brand',
        city: 'Bakı',
        sellerPhone: '+994501234567',
        sellerName: 'Seller',
        sellerId: 'seller-1',
        sellerAvatarUrl: 'https://cdn.example.com/seller.jpg',
      ),
    );

    expect(listing.id, 'discover-1');
    expect(listing.phoneNumber, '+994501234567');
    expect(listing.city, 'Bakı');
    expect(listing.sellerName, 'Seller');
    expect(listing.sellerId, 'seller-1');
    expect(listing.sellerAvatar, 'https://cdn.example.com/seller.jpg');
    expect(listing.imagePath, 'poster.jpg');
  });

  test('home bloc loads and appends the next page', () async {
    final bloc = HomeBloc(repository: MockHomeRepository());
    addTearDown(bloc.close);

    final firstStateFuture = bloc.stream.firstWhere(
      (state) => state.status == HomeStatus.success && state.nextPage != null,
    );
    bloc.add(const HomeListingsRequested());
    final firstState = await firstStateFuture;
    expect(firstState.listings, hasLength(5));
    expect(firstState.listings.first, isA<FeedItem>());
    expect(firstState.nextPage, 2);

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
    expect(state.nextPage, isNull);
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
      final page = await repository.fetchListings(size: 50);

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
      final azerbaijanProduct = page.listings
          .firstWhere((item) => item.id == 'listing-1')
          .product!;
      expect(azerbaijanProduct.price, 2890.24);
      expect(azerbaijanProduct.currency, 'AZN');
      final turkishProduct = page.listings
          .firstWhere((item) => item.id == 'listing-7')
          .product!;
      expect(turkishProduct.price, 1250000);
      expect(turkishProduct.currency, 'TRY');
    },
  );
}
