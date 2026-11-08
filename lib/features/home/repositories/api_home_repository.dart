import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/models/video/feed_item.dart';
import 'package:vidsell/models/common/page_response.dart';
import 'package:vidsell/models/enums/feed_tab.dart';
import 'package:vidsell/models/enums/seller_type.dart';

class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._client);

  final ApiClient _client;

  @override
  Future<PageResponse<FeedItem>> fetchListings({
    String? cursor,
    int limit = 5,
    String? categoryId,
    String? subcategoryId,
    String? cityId,
    String? sellerId,
    FeedTab tab = FeedTab.forYou,
    double? latitude,
    double? longitude,
    SellerType? sellerType,
  }) async {
    final data = await _client.get(
      '/listings',
      queryParameters: {
        'cursor': ?cursor,
        'limit': limit,
        'categoryId': ?categoryId,
        'subcategoryId': ?subcategoryId,
        'cityId': ?cityId,
        'sellerId': ?sellerId,
        'tab': tab.code,
        'lat': ?latitude,
        'lng': ?longitude,
        'sellerType': ?sellerType?.code,
      },
    );
    final page = parsePage(data, FeedItem.fromJson);
    return PageResponse(
      items: page.items,
      page: page.page,
      size: page.size,
      totalElements: page.totalElements,
      totalPages: page.totalPages,
      last: page.last,
      nextCursor: data is Map<String, dynamic>
          ? data['nextCursor'] as String?
          : null,
    );
  }
}
