import 'package:vidsell/models/enums/feed_tab.dart';
import 'package:vidsell/models/enums/seller_type.dart';
import 'package:vidsell/models/common/page_response.dart';
import 'package:vidsell/models/video/feed_item.dart';

abstract interface class HomeRepository {
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
  });
}
