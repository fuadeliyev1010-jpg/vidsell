import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

abstract interface class UserListingRepository {
  Future<List<Product>> fetchMyListings({ProductStatus? status});
  Future<void> updateListingStatus(String listingId, ProductStatus status);
  Future<void> deleteListing(String listingId);
}
