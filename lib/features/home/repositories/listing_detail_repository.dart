import 'package:vidsell/models/product/product.dart';

abstract interface class ListingDetailRepository {
  Future<Product> fetchListing(String listingId);
}
