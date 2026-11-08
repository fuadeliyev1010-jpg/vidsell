import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/models/product/product.dart';

abstract interface class ListingRepository {
  /// TODO(api): API.md has no image-upload endpoint; only mock mode supports it.
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
