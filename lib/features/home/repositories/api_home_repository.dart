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
    bool productsOnly = false,
  }) async {
    final useProducts =
        productsOnly ||
        categoryId != null ||
        subcategoryId != null ||
        cityId != null ||
        sellerId != null ||
        sellerType != null;
    final data = useProducts
        ? await _client.get(
            '/products',
            queryParameters: {
              'page': page - 1,
              'size': size,
              'category': ?_categoryCode(categoryId),
              'subcategory': ?subcategoryId?.toUpperCase(),
              'city': ?cityId,
              'sellerId': ?sellerId,
              'sellerType': ?sellerType?.code,
              'lat': ?latitude,
              'lng': ?longitude,
            },
          )
        : await _client.get(
            '/feed',
            queryParameters: {
              'page': page,
              'size': size,
              'tab': tab.code,
              'lat': ?latitude,
              'lng': ?longitude,
            },
          );
    if (useProducts) {
      final responsePage = parsePage(
        data,
        (json) => FeedItem.fromJson(json, mediaOrigin: _client.mediaOrigin),
        requestedPage: page - 1,
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
    final responsePage = parsePage(
      data,
      (json) => FeedItem.fromJson(json, mediaOrigin: _client.mediaOrigin),
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

  static String? _categoryCode(String? categoryId) => switch (categoryId) {
    'electronics' => 'ELECTRONICS',
    'vehicles' || 'transport' => 'TRANSPORT',
    'real-estate' => 'REAL_ESTATE',
    'home-appliances' => 'HOME_APPLIANCES',
    'special-occasion-clothing' => 'SPECIAL_OCCASION',
    'cosmetics' => 'COSMETICS',
    null => null,
    _ => categoryId.toUpperCase(),
  };
}
