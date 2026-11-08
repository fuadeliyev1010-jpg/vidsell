import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';
import 'package:vidsell/models/enums/feed_tab.dart';
import 'package:vidsell/models/enums/seller_type.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/video/feed_item.dart';

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
  final List<FeedItem> listings;
  final int? nextPage;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.listings = const [],
    this.nextPage,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<FeedItem>? listings,
    String? errorMessage,
    int? nextPage,
    bool clearError = false,
    bool clearNextPage = false,
  }) => HomeState(
    status: status ?? this.status,
    listings: listings ?? this.listings,
    nextPage: clearNextPage ? null : nextPage ?? this.nextPage,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
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
    final listings = state.listings.map((item) {
      final products = item.products.map((product) {
        if (product.id != event.listingId) return product;
        return Product.fromJson({
          ...product.toJson(),
          'isFavorite': event.isFavorite,
        });
      }).toList(growable: false);
      return item.copyWith(products: products);
    }).toList(growable: false);
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
        clearNextPage: event.refresh,
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
          nextPage: page.nextPage,
          clearNextPage: page.nextPage == null,
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
    final pageNumber = state.nextPage;
    if (state.status == HomeStatus.loadingMore ||
        state.status == HomeStatus.loading ||
        pageNumber == null) {
      return;
    }

    final requestVersion = _requestVersion;
    emit(state.copyWith(status: HomeStatus.loadingMore, clearError: true));
    try {
      final page = await _fetchPage(_query, page: pageNumber);
      if (requestVersion != _requestVersion) return;
      final listings = _sortByDistance(
        _uniqueVideoListings([...state.listings, ...page.listings]),
        _query,
      );
      emit(
        state.copyWith(
          status: HomeStatus.success,
          listings: List.unmodifiable(listings),
          nextPage: page.nextPage,
          clearNextPage: page.nextPage == null,
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

  Future<_VideoFeedPage> _fetchPage(
    HomeFeedQuery query, {
    int page = 1,
  }) async {
    final sellerIds = query.sellerIds;
    if (sellerIds != null) {
      if (sellerIds.isEmpty || page > 1) {
        return const _VideoFeedPage(listings: [], nextPage: null);
      }
      final pages = await Future.wait(
        sellerIds.map((sellerId) => _fetchAllListings(sellerId: sellerId)),
      );
      return _VideoFeedPage(
        listings: List.unmodifiable(
          _sortByCreatedAt(_uniqueVideoListings(pages.expand((items) => items))),
        ),
        nextPage: null,
      );
    }

    final categoryIds = query.categoryIds;
    if (categoryIds != null) {
      if (categoryIds.isEmpty || page > 1) {
        return const _VideoFeedPage(listings: [], nextPage: null);
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
      return _VideoFeedPage(
        listings: List.unmodifiable(
          _sortByCreatedAt(_uniqueVideoListings(pages.expand((items) => items))),
        ),
        nextPage: null,
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
      return _VideoFeedPage(
        listings: List.unmodifiable(
          _sortByDistance(_uniqueVideoListings(allListings), query),
        ),
        nextPage: null,
      );
    }

    final response = await _repository.fetchListings(
      page: page,
      size: query.pageSize,
      cityId: query.cityId,
      tab: query.tab,
      latitude: query.latitude,
      longitude: query.longitude,
      sellerType: query.sellerType,
    );
    final listings = _sortByDistance(
      _uniqueVideoListings(response.items),
      query,
    );
    return _VideoFeedPage(
      listings: List.unmodifiable(listings),
      nextPage: response.last ? null : response.page + 2,
    );
  }

  Future<List<FeedItem>> _fetchAllListings({
    String? categoryId,
    String? cityId,
    String? sellerId,
    FeedTab tab = FeedTab.forYou,
    double? latitude,
    double? longitude,
    SellerType? sellerType,
  }) async {
    final listings = <FeedItem>[];
    var requestPage = 1;
    while (true) {
      final response = await _repository.fetchListings(
        page: requestPage,
        size: 50,
        categoryId: categoryId,
        cityId: cityId,
        sellerId: sellerId,
        tab: tab,
        latitude: latitude,
        longitude: longitude,
        sellerType: sellerType,
      );
      listings.addAll(response.items);
      if (response.last) break;
      if (response.page != requestPage - 1 ||
          requestPage >= response.totalPages) {
        throw StateError(
          'Invalid feed pagination response for request page $requestPage.',
        );
      }
      requestPage++;
    }
    return listings;
  }

  List<FeedItem> _uniqueVideoListings(Iterable<FeedItem> listings) {
    final unique = <String, FeedItem>{};
    for (final item in listings) {
      if (item.videoUrl?.trim().isNotEmpty == true) {
        unique.putIfAbsent(item.videoId, () => item);
      }
    }
    return unique.values.toList(growable: false);
  }

  List<FeedItem> _sortByDistance(
    List<FeedItem> listings,
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

  List<FeedItem> _sortByCreatedAt(List<FeedItem> listings) {
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

  double _distanceKm(FeedItem item, double latitude, double longitude) {
    final itemLatitude = item.latitude;
    final itemLongitude = item.longitude;
    if (itemLatitude == null || itemLongitude == null) {
      return double.infinity;
    }
    const earthRadiusKm = 6371.0;
    final latitudeDelta = _radians(itemLatitude - latitude);
    final longitudeDelta = _radians(itemLongitude - longitude);
    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(_radians(latitude)) *
            math.cos(_radians(itemLatitude)) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return earthRadiusKm * 2 * math.asin(math.sqrt(haversine));
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}

class _VideoFeedPage {
  const _VideoFeedPage({required this.listings, required this.nextPage});

  final List<FeedItem> listings;
  final int? nextPage;
}
