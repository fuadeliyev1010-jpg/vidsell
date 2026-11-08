import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/models/product/product.dart';

abstract interface class ListingRepository {
  /// API mode accepts hosted image URLs because OpenAPI has no upload route.
  Future<List<String>> uploadImages(List<String> localPaths);

  Future<Product> createListing(ListingDraft draft);
}

class ProductVideoAttachmentException implements Exception {
  const ProductVideoAttachmentException({
    required this.product,
    required this.cause,
  });

  final Product product;
  final Object cause;
}
