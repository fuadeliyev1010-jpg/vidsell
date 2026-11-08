import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';
import 'package:vidsell/models/enums/feed_tab.dart';
import 'package:vidsell/models/enums/seller_type.dart';
import 'package:vidsell/core/adapters/product_legacy_adapter.dart';

enum HomeStatus { initial, loading, loadingMore, success, failure }

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeListingsRequested extends HomeEvent {
  const HomeListingsRequested({
    this.refresh = false,
    this.query = const HomeFeedQuery(),
  });

  final bool refresh;
  final HomeFeedQuery query;
}

final class HomeMoreListingsRequested extends HomeEvent {
  const HomeMoreListingsRequested();
}

final class HomeListingFavoriteChanged extends HomeEvent {
  const HomeListingFavoriteChanged({
    required this.listingId,
    required this.isFavorite,
  });

  final String listingId;
  final bool isFavorite;
}

final class HomeFeedQuery {
  const HomeFeedQuery({
    this.tab = FeedTab.forYou,
    this.cityId,
    this.sellerIds,
    this.categoryIds,
    this.latitude,
    this.longitude,
    this.sellerType,
  });

  final FeedTab tab;
  final String? cityId;
  final List<String>? sellerIds;
  final List<String>? categoryIds;
  final double? latitude;
  final double? longitude;
  final SellerType? sellerType;

  bool get isNearby => latitude != null && longitude != null || cityId != null;

  int get pageSize => isNearby ? 50 : 5;
}

final class HomeState {
  final HomeStatus status;
  final List<HomeListing> listings;
  final String? nextCursor;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.listings = const [],
    this.nextCursor,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<HomeListing>? listings,
    String? errorMessage,
    String? nextCursor,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({HomeRepository? repository})
    : _repository = repository ?? MockHomeRepository(),
      super(const HomeState()) {
    on<HomeListingsRequested>(_onListingsRequested);
    on<HomeMoreListingsRequested>(_onMoreListingsRequested);
    on<HomeListingFavoriteChanged>(_onListingFavoriteChanged);
  }

  final HomeRepository _repository;
  HomeFeedQuery _query = const HomeFeedQuery();
  int _requestVersion = 0;

  void _onListingFavoriteChanged(
    HomeListingFavoriteChanged event,
    Emitter<HomeState> emit,
  ) {
    final listings = state.listings
        .map(
          (listing) => listing.id == event.listingId
              ? listing.copyWith(isFavorite: event.isFavorite)
              : listing,
        )
        .toList(growable: false);
    emit(state.copyWith(listings: listings));
  }

  Future<void> _onListingsRequested(
    HomeListingsRequested event,
    Emitter<HomeState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    _query = event.query;
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        listings: event.refresh ? const [] : state.listings,
        nextCursor: event.refresh ? null : state.nextCursor,
        clearCursor: event.refresh,
        clearError: true,
      ),
    );

    try {
      final page = await _fetchPage(event.query);
      if (requestVersion != _requestVersion) return;
      emit(
        state.copyWith(
          status: HomeStatus.success,
          listings: List.unmodifiable(page.listings),
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
        ),
      );
    } catch (error) {
      if (requestVersion != _requestVersion) return;
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onMoreListingsRequested(
    HomeMoreListingsRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.status == HomeStatus.loadingMore ||
        state.status == HomeStatus.loading ||
        state.nextCursor == null) {
      return;
    }

    final requestVersion = _requestVersion;
    emit(state.copyWith(status: HomeStatus.loadingMore, clearError: true));
    try {
      final page = await _fetchPage(_query, cursor: state.nextCursor);
      if (requestVersion != _requestVersion) return;
      final listings = _uniqueVideoListings([
        ...state.listings,
        ...page.listings,
      ]);
      final sortedListings = _sortByDistance(listings, _query);
      emit(
        state.copyWith(
          status: HomeStatus.success,
          listings: List.unmodifiable(sortedListings),
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
        ),
      );
    } catch (error) {
      if (requestVersion != _requestVersion) return;
      emit(
        state.copyWith(
          status: HomeStatus.success,
          errorMessage: error.toString(),
        ),
      );
    }

  }

  Future<_VideoListingPage> _fetchPage(
    HomeFeedQuery query, {
    String? cursor,
  }) async {
    final sellerIds = query.sellerIds;
    if (sellerIds != null) {
      if (sellerIds.isEmpty || cursor != null) {
        return const _VideoListingPage(listings: [], nextCursor: null);
      }

      final pages = await Future.wait(
        sellerIds.map((sellerId) => _fetchAllListings(sellerId: sellerId)),
      );
      final listings = _uniqueVideoListings(pages.expand((page) => page));
      return _VideoListingPage(
        listings: List.unmodifiable(_sortByCreatedAt(listings)),
        nextCursor: null,
      );
    }

    final categoryIds = query.categoryIds;
    if (categoryIds != null) {
      if (categoryIds.isEmpty || cursor != null) {
        return const _VideoListingPage(listings: [], nextCursor: null);
      }

      final pages = await Future.wait(
        categoryIds.map(
          (categoryId) => _fetchAllListings(
            categoryId: categoryId,
            tab: query.tab,
            sellerType: query.sellerType,
          ),
        ),
      );
      final listings = _uniqueVideoListings(pages.expand((page) => page));
      return _VideoListingPage(
        listings: List.unmodifiable(_sortByCreatedAt(listings)),
        nextCursor: null,
      );
    }

    if (query.latitude != null && query.longitude != null) {
      final allListings = await _fetchAllListings(
        cityId: query.cityId,
        tab: query.tab,
        latitude: query.latitude,
        longitude: query.longitude,
        sellerType: query.sellerType,
      );
      return _VideoListingPage(
        listings: List.unmodifiable(
          _sortByDistance(_uniqueVideoListings(allListings), query),
        ),
        nextCursor: null,
      );
    }

    final page = await _repository.fetchListings(
      cursor: cursor,
      limit: query.pageSize,
      cityId: query.cityId,
      tab: query.tab,
      latitude: query.latitude,
      longitude: query.longitude,
      sellerType: query.sellerType,
    );
    final listings = page.items
        .map(ProductLegacyAdapter.toHomeListingFromFeedItem)
        .where((listing) => listing.hasVideo);
    return _VideoListingPage(
      listings: List.unmodifiable(_sortByDistance(listings.toList(), query)),
      nextCursor: page.nextCursor,
    );
  }

  Future<List<HomeListing>> _fetchAllListings({
    String? categoryId,
    String? cityId,
    String? sellerId,
    FeedTab tab = FeedTab.forYou,
    double? latitude,
    double? longitude,
    SellerType? sellerType,
  }) async {
    final listings = <HomeListing>[];
    final visitedCursors = <String>{};
    String? cursor;
    do {
      final page = await _repository.fetchListings(
        cursor: cursor,
        limit: 50,
        categoryId: categoryId,
        cityId: cityId,
        sellerId: sellerId,
        tab: tab,
        latitude: latitude,
        longitude: longitude,
        sellerType: sellerType,
      );
      listings.addAll(
        page.items.map(ProductLegacyAdapter.toHomeListingFromFeedItem),
      );
      final nextCursor = page.nextCursor;
      if (nextCursor == null || !visitedCursors.add(nextCursor)) break;
      cursor = nextCursor;
    } while (true);
    return listings;
  }

  List<HomeListing> _uniqueVideoListings(Iterable<HomeListing> listings) {
    final unique = <String, HomeListing>{};
    for (final listing in listings) {
      if (listing.hasVideo) unique.putIfAbsent(listing.id, () => listing);
    }
    return unique.values.toList(growable: false);
  }

  List<HomeListing> _sortByDistance(
    List<HomeListing> listings,
    HomeFeedQuery query,
  ) {
    final latitude = query.latitude;
    final longitude = query.longitude;
    if (latitude == null || longitude == null) return listings;

    final sorted = [...listings];
    sorted.sort((a, b) {
      final distanceDifference =
          _distanceKm(a, latitude, longitude) -
          _distanceKm(b, latitude, longitude);
      return distanceDifference.isNaN ? 0 : distanceDifference.compareTo(0);
    });
    return sorted;
  }

  List<HomeListing> _sortByCreatedAt(List<HomeListing> listings) {
    final sorted = [...listings];
    sorted.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate == null) return bDate == null ? 0 : 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  double _distanceKm(HomeListing listing, double latitude, double longitude) {
    final listingLatitude = listing.latitude;
    final listingLongitude = listing.longitude;
    if (listingLatitude == null || listingLongitude == null) {
      return double.infinity;
    }
    const earthRadiusKm = 6371.0;
    final latitudeDelta = _radians(listingLatitude - latitude);
    final longitudeDelta = _radians(listingLongitude - longitude);
    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(_radians(latitude)) *
            math.cos(_radians(listingLatitude)) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return earthRadiusKm * 2 * math.asin(math.sqrt(haversine));
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}

class _VideoListingPage {
  const _VideoListingPage({required this.listings, required this.nextCursor});

  final List<HomeListing> listings;
  final String? nextCursor;
}
