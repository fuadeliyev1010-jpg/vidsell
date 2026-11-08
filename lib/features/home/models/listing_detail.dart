import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/core/adapters/product_legacy_adapter.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';

/// @deprecated Detail repositories return [Product] directly.
class ListingDetail {
  static Product fromListing(Listing listing) =>
      ProductLegacyAdapter.fromHomeListing(HomeListing.fromListing(listing));
}
