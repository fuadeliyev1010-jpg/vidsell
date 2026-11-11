import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/models/saved_search.dart';
import 'package:vidsell/models/common/page_response.dart';
import 'package:vidsell/models/social/comment.dart';
import 'package:vidsell/models/social/favorite.dart';
import 'package:vidsell/models/social/like.dart';
import 'package:vidsell/models/social/report_request.dart';
import 'package:vidsell/models/social/review.dart';
import 'package:vidsell/models/social/review_page.dart';

abstract interface class EngagementRepository {
  Future<List<Favorite>> fetchFavoriteModels();

  Future<LikeResponse> setVideoLike({
    required String videoId,
    required bool liked,
  });

  Future<PageResponse<Comment>> fetchVideoComments(
    String videoId, {
    int page = 1,
  });

  Future<Comment> addVideoComment({
    required String videoId,
    required String content,
  });

  Future<void> deleteVideoComment(String videoId, String commentId);

  Future<ReviewPage> fetchProductReviews(String productId, {int page = 1});

  Future<Review> addProductReview({
    required String productId,
    required double rating,
    required String comment,
  });

  Future<void> submitListingReport({
    required String listingId,
    required ReportRequest request,
  });

  Future<List<EngagementItem>> fetchFavorites();
  Future<void> setFavorite(
    String listingId,
    bool enabled, {
    EngagementItem? item,
  });
  Future<void> clearFavorites();
  Future<List<EngagementItem>> fetchFollowedStores();
  Future<void> setFollowing(
    String storeId,
    bool enabled, {
    EngagementItem? item,
  });
  Future<void> clearFollowedStores();
  Future<List<SavedSearch>> fetchSavedSearches();
  Future<SavedSearch> saveSearch(String query);
  Future<void> deleteSavedSearch(String savedSearchId);
  Future<void> clearSavedSearches();
  Future<void> reportListing({
    required String listingId,
    required String reason,
    required String description,
  });
  Future<void> blockUser(String userId);
}
