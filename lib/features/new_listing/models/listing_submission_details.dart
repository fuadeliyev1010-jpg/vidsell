import 'package:vidsell/features/new_listing/models/listing.dart';

class ListingSubmissionDetails {
  const ListingSubmissionDetails({
    required this.title,
    required this.price,
    required this.city,
    required this.categoryName,
    required this.subcategoryName,
    this.listingId,
    this.status = ListingStatus.unknown,
  });

  final String title;
  final String price;
  final String city;
  final String categoryName;
  final String subcategoryName;
  final String? listingId;
  final ListingStatus status;
}
