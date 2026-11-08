import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/models/saved_search.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/models/common/page_response.dart';
import 'package:vidsell/models/social/comment.dart';
import 'package:vidsell/models/social/favorite.dart';
import 'package:vidsell/models/social/like.dart';
import 'package:vidsell/models/social/report_request.dart';
import 'package:vidsell/models/social/review.dart';
import 'package:vidsell/models/social/review_page.dart';

class MockEngagementRepository implements EngagementRepository {
  static final instance = MockEngagementRepository(
    sessionStore: InMemorySessionStore(),
  );

  MockEngagementRepository({required SessionStore sessionStore})
    : _sessionStore = sessionStore;

  final SessionStore _sessionStore;
  final Map<String, Map<String, EngagementItem>> _favoritesByUser = {};
  final Map<String, Map<String, EngagementItem>> _followingByUser = {};
  final Map<String, List<SavedSearch>> _savedSearchesByUser = {};
  final Map<String, LikeResponse> _videoLikes = {};
  final Map<String, List<Comment>> _videoComments = {};
  final Map<String, List<Review>> _productReviews = {};

  @override
  Future<List<Favorite>> fetchFavoriteModels() async {
    final items = await fetchFavorites();
    return items
        .map(
          (item) => Favorite(
            id: item.id,
            title: item.title,
            price:
                double.tryParse(
                  item.subtitle.replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0,
            city: '',
            imageUrl: item.imageUrl,
            sellerId: '',
            favoritedAt: null,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<LikeResponse> setVideoLike({
    required String videoId,
    required bool liked,
  }) async {
    final current = _videoLikes[videoId];
    final response = LikeResponse(
      videoId: videoId,
      liked: liked,
      likeCount: (current?.likeCount ?? 0) + (liked ? 1 : -1),
    );
    _videoLikes[videoId] = response;
    return response;
  }

  @override
  Future<PageResponse<Comment>> fetchVideoComments(
    String videoId, {
    int page = 1,
  }) async {
    final items = _videoComments[videoId] ?? const [];
    return PageResponse(
      items: items,
      page: page,
      size: items.length,
      totalElements: items.length,
      totalPages: items.isEmpty ? 0 : 1,
      last: true,
    );
  }

  @override
  Future<Comment> addVideoComment({
    required String videoId,
    required String content,
  }) async {
    final comment = Comment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      videoId: videoId,
      authorId: await _userScope,
      authorFullName: 'You',
      content: content,
      createdAt: DateTime.now(),
    );
    _videoComments.putIfAbsent(videoId, () => []).add(comment);
    return comment;
  }

  @override
  Future<void> deleteVideoComment(String commentId) async {
    for (final comments in _videoComments.values) {
      comments.removeWhere((comment) => comment.id == commentId);
    }
  }

  @override
  Future<ReviewPage> fetchProductReviews(
    String productId, {
    int page = 1,
  }) async {
    final items = _productReviews[productId] ?? const [];
    final average = items.isEmpty
        ? 0.0
        : items.map((item) => item.rating).reduce((a, b) => a + b) /
              items.length;
    return ReviewPage(
      averageRating: average,
      reviewCount: items.length,
      items: items,
    );
  }

  @override
  Future<Review> addProductReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final review = Review(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorId: await _userScope,
      authorFullName: 'You',
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _productReviews.putIfAbsent(productId, () => []).add(review);
    return review;
  }

  @override
  Future<void> submitListingReport({
    required String listingId,
    required ReportRequest request,
  }) async {}

  static const Map<String, EngagementItem> _knownListingMeta = {
    'listing-1': EngagementItem(
      id: 'listing-1',
      title: 'Smartfon Apple iPhone 17 Pro 256GB Cosmic Orange MG7L4LL/A',
      imageUrl: 'assets/images/e67668b0c9a2fc774625fba8ecf0c43e8360420b.gif',
      subtitle: '2890.24 ₼',
      categoryId: 'electronics',
    ),
    'listing-2': EngagementItem(
      id: 'listing-2',
      title: 'Samsung Galaxy S24 Ultra 512GB',
      imageUrl: 'assets/images/e67668b0c9a2fc774625fba8ecf0c43e8360420b.gif',
      subtitle: '1749.00 ₼',
      categoryId: 'electronics',
    ),
    'listing-3': EngagementItem(
      id: 'listing-3',
      title: 'Sony WH-1000XM5 simsiz qulaqlıq',
      imageUrl: 'assets/images/e67668b0c9a2fc774625fba8ecf0c43e8360420b.gif',
      subtitle: '420.00 ₼',
      categoryId: 'electronics',
    ),
    'listing-4': EngagementItem(
      id: 'listing-4',
      title: 'Apple MacBook Air M2',
      imageUrl: 'assets/images/e67668b0c9a2fc774625fba8ecf0c43e8360420b.gif',
      subtitle: '899.00 ₼',
      categoryId: 'electronics',
    ),
    'listing-5': EngagementItem(
      id: 'listing-5',
      title: 'PlayStation 5 Slim',
      imageUrl: 'assets/images/e67668b0c9a2fc774625fba8ecf0c43e8360420b.gif',
      subtitle: '1250.00 ₼',
      categoryId: 'electronics',
    ),
    'listing-6': EngagementItem(
      id: 'listing-6',
      title: 'Google Pixel 9 Pro',
      imageUrl: 'https://cdn.example.com/listings/6.jpg',
      subtitle: '649.00 ₼',
      categoryId: 'electronics',
    ),
  };

  @override
  Future<List<EngagementItem>> fetchFavorites() async {
    final favorites = _favoritesByUser[await _userScope] ?? const {};
    return favorites.values.toList().reversed.toList(growable: false);
  }

  @override
  Future<void> setFavorite(
    String listingId,
    bool enabled, {
    EngagementItem? item,
  }) async {
    final favorites = _favoritesByUser.putIfAbsent(await _userScope, () => {});
    if (enabled) {
      favorites[listingId] =
          item ??
          _knownListingMeta[listingId] ??
          EngagementItem(
            id: listingId,
            title: 'Seçilmiş elan',
            imageUrl: null,
            subtitle: '',
          );
    } else {
      favorites.remove(listingId);
    }
  }

  @override
  Future<void> clearFavorites() async =>
      _favoritesByUser.remove(await _userScope);

  @override
  Future<List<EngagementItem>> fetchFollowedStores() async {
    final followed = _followingByUser[await _userScope] ?? const {};
    return followed.values.toList().reversed.toList(growable: false);
  }

  @override
  Future<void> setFollowing(
    String storeId,
    bool enabled, {
    EngagementItem? item,
  }) async {
    final following = _followingByUser.putIfAbsent(await _userScope, () => {});
    if (enabled) {
      following[storeId] =
          item ??
          EngagementItem(
            id: storeId,
            title: storeId,
            imageUrl: null,
            subtitle: 'Mağaza',
          );
    } else {
      following.remove(storeId);
    }
  }

  @override
  Future<void> clearFollowedStores() async =>
      _followingByUser.remove(await _userScope);

  @override
  Future<List<SavedSearch>> fetchSavedSearches() async =>
      List.unmodifiable(_savedSearchesByUser[await _userScope] ?? const []);

  @override
  Future<SavedSearch> saveSearch(String query) async {
    final searches = _savedSearchesByUser.putIfAbsent(
      await _userScope,
      () => [],
    );
    final saved = SavedSearch(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      query: query,
      createdAt: DateTime.now(),
    );
    searches.removeWhere((item) => item.query == query);
    searches.insert(0, saved);
    return saved;
  }

  @override
  Future<void> deleteSavedSearch(String savedSearchId) async {
    _savedSearchesByUser[await _userScope]?.removeWhere(
      (item) => item.id == savedSearchId,
    );
  }

  @override
  Future<void> clearSavedSearches() async =>
      _savedSearchesByUser.remove(await _userScope);

  Future<String> get _userScope async {
    final session = await _sessionStore.read();
    return session?.user.id ?? 'anonymous';
  }

  @override
  Future<void> reportListing({
    required String listingId,
    required String reason,
    required String description,
  }) async {}

  @override
  Future<void> blockUser(String userId) async {}
}
