import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/models/saved_search.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/models/common/page_response.dart';
import 'package:vidsell/models/social/comment.dart';
import 'package:vidsell/models/social/favorite.dart';
import 'package:vidsell/models/social/like.dart';
import 'package:vidsell/models/social/report_request.dart';
import 'package:vidsell/models/social/review.dart';
import 'package:vidsell/models/social/review_page.dart';
import 'package:vidsell/models/enums/report_reason.dart';

class ApiEngagementRepository implements EngagementRepository {
  ApiEngagementRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Favorite>> fetchFavoriteModels() async {
    final data = await _client.get('/me/favorites');
    return parsePage(data, Favorite.fromJson, itemKey: 'favorites').items;
  }

  @override
  Future<LikeResponse> setVideoLike({
    required String videoId,
    required bool liked,
  }) async {
    final data = liked
        ? await _client.post('/videos/$videoId/like')
        : await _client.delete('/videos/$videoId/like');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid video like response.');
    }
    return LikeResponse.fromJson(data);
  }

  @override
  Future<PageResponse<Comment>> fetchVideoComments(
    String videoId, {
    int page = 1,
  }) async {
    final data = await _client.get(
      '/videos/$videoId/comments',
      queryParameters: {'page': page - 1},
    );
    return parsePage(
      data,
      Comment.fromJson,
      requestedPage: page,
      itemKey: 'comments',
    );
  }

  @override
  Future<Comment> addVideoComment({
    required String videoId,
    required String content,
  }) async {
    final data = await _client.post(
      '/videos/$videoId/comments',
      data: {'content': content},
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid comment response.');
    }
    return Comment.fromJson(data);
  }

  @override
  Future<void> deleteVideoComment(String commentId) async {
    await _client.delete('/comments/$commentId');
  }

  @override
  Future<ReviewPage> fetchProductReviews(
    String productId, {
    int page = 1,
  }) async {
    final data = await _client.get(
      '/products/$productId/reviews',
      queryParameters: {'page': page - 1},
    );
    final pageResponse = parsePage(
      data,
      Review.fromJson,
      requestedPage: page,
      itemKey: 'reviews',
    );
    final envelope = data is Map<String, dynamic> ? data : const {};
    return ReviewPage(
      averageRating: _double(envelope['averageRating']),
      reviewCount: _int(envelope['reviewCount'], pageResponse.totalElements),
      items: pageResponse.items,
    );
  }

  @override
  Future<Review> addProductReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final data = await _client.post(
      '/products/$productId/reviews',
      data: {'rating': rating, 'comment': comment},
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid review response.');
    }
    return Review.fromJson(data);
  }

  @override
  Future<void> submitListingReport({
    required String listingId,
    required ReportRequest request,
  }) async {
    await _client.post('/listings/$listingId/reports', data: request.toJson());
  }

  @override
  Future<List<EngagementItem>> fetchFavorites() async {
    final favorites = await fetchFavoriteModels();
    return favorites
        .map(
          (favorite) => EngagementItem(
            id: favorite.id,
            title: favorite.title,
            imageUrl: favorite.imageUrl,
            subtitle: favorite.price.toString(),
            categoryId: favorite.category?.code,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> setFavorite(
    String listingId,
    bool enabled, {
    EngagementItem? item,
  }) async {
    if (enabled) {
      await _client.post('/listings/$listingId/favorite');
    } else {
      await _client.delete('/listings/$listingId/favorite');
    }
  }

  @override
  Future<void> clearFavorites() async {
    await _client.delete('/me/favorites');
  }

  @override
  Future<List<EngagementItem>> fetchFollowedStores() => _items('/me/follows');

  @override
  Future<void> setFollowing(
    String storeId,
    bool enabled, {
    EngagementItem? item,
  }) async {
    if (enabled) {
      await _client.post('/stores/$storeId/follow');
    } else {
      await _client.delete('/stores/$storeId/follow');
    }
  }

  @override
  Future<void> clearFollowedStores() async {
    await _client.delete('/me/follows');
  }

  @override
  Future<List<SavedSearch>> fetchSavedSearches() async {
    final data = await _client.get('/me/saved-searches');
    return parsePage(
      data,
      SavedSearch.fromJson,
      itemKey: 'savedSearches',
    ).items;
  }

  @override
  Future<SavedSearch> saveSearch(String query) async {
    final data = await _client.post(
      '/me/saved-searches',
      data: {'query': query},
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid saved search response.');
    }
    return SavedSearch.fromJson(data);
  }

  @override
  Future<void> deleteSavedSearch(String savedSearchId) async {
    await _client.delete('/me/saved-searches/$savedSearchId');
  }

  @override
  Future<void> clearSavedSearches() async {
    await _client.delete('/me/saved-searches');
  }

  @override
  Future<void> reportListing({
    required String listingId,
    required String reason,
    required String description,
  }) async {
    final reportReason = ReportReason.fromCode(reason.toUpperCase());
    if (reportReason == null) {
      throw ArgumentError.value(reason, 'reason', 'Unknown report reason');
    }
    await submitListingReport(
      listingId: listingId,
      request: ReportRequest(reason: reportReason, description: description),
    );
  }

  @override
  Future<void> blockUser(String userId) async {
    await _client.post('/users/$userId/block');
  }

  Future<List<EngagementItem>> _items(String path) async {
    final data = await _client.get(path);
    return parsePage(data, EngagementItem.fromJson).items;
  }

  static double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static int _int(dynamic value, int fallback) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
}
