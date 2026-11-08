import 'package:vidsell/features/new_listing/models/created_listing.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';

abstract interface class ListingRepository {
  Future<CreatedListing> createListing(ListingDraft draft);
}
