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
    int page = 1,
    int size = 5,
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
        'page': page,
        'size': size,
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
    final responsePage = parsePage(
      data,
      FeedItem.fromJson,
      requestedPage: page,
    );
    return PageResponse(
      items: responsePage.items,
      page: responsePage.page,
      size: responsePage.size,
      totalElements: responsePage.totalElements,
      totalPages: responsePage.totalPages,
      last: responsePage.last,
    );
  }
}
