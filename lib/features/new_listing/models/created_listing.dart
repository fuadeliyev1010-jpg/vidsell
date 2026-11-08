import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/enums/product_status.dart';

class CreatedListing {
  const CreatedListing({
    required this.id,
    required this.status,
    required this.shareUrl,
    this.product,
  });

  final String id;
  final ListingStatus status;
  final String shareUrl;
  final Product? product;

  factory CreatedListing.fromProduct(Product product) => CreatedListing(
    id: product.id,
    status: _status(product.status),
    shareUrl: product.shareUrl ?? '',
    product: product,
  );

  static ListingStatus _status(ProductStatus? status) => switch (status) {
    ProductStatus.active => ListingStatus.active,
    ProductStatus.sold => ListingStatus.sold,
    ProductStatus.underReview => ListingStatus.pendingModeration,
    ProductStatus.inactive => ListingStatus.inactive,
    ProductStatus.rejected => ListingStatus.rejected,
    ProductStatus.pendingPayment => ListingStatus.pendingPayment,
    ProductStatus.deleted => ListingStatus.deleted,
    ProductStatus.unknown => ListingStatus.unknown,
    null => ListingStatus.unknown,
  };
}
