import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/api_video_repository.dart';
import 'package:vidsell/features/new_listing/repositories/listing_repository.dart';
import 'package:vidsell/models/enums/product_category.dart';
import 'package:vidsell/models/enums/product_condition.dart';
import 'package:vidsell/models/enums/product_subcategory.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/product/product_request.dart';

class ApiListingRepository implements ListingRepository {
  ApiListingRepository(this._client);

  final ApiClient _client;

  ApiVideoRepository get _videos => ApiVideoRepository(_client);

  @override
  Future<List<String>> uploadImages(List<String> localPaths) async {
    throw UnsupportedError(
      'Product image uploads are unavailable in API mode.',
    );
  }

  @override
  Future<Product> createListing(ListingDraft draft) async {
    if (draft.videoPaths.length > 1) {
      throw StateError('A product can be tagged to only one video.');
    }

    final request = ProductRequest(
      title: draft.title,
      price: draft.price,
      currency: draft.currency,
      description: draft.description,
      category: _category(draft.categoryId),
      subcategory: draft.subcategoryId.isEmpty
          ? null
          : ProductSubcategory.fromCode(draft.subcategoryId),
      city: draft.city,
      condition: _condition(draft.condition),
      brand: draft.brand.isEmpty ? null : draft.brand,
      modelName: draft.model.isEmpty ? null : draft.model,
      imageUrls: [
        for (final imageUrl in draft.imagePaths)
          if (_isRemoteUrl(imageUrl)) imageUrl,
      ],
    );
    final data = await _client.post('/products', data: request.toJson());
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid product response.');
    }
    final product = Product.fromJson(data);
    if (product.id.trim().isEmpty) {
      throw StateError('Product response has no ID.');
    }
    if (product.status == null) {
      throw StateError('Product response has no status.');
    }

    if (draft.videoPaths.isNotEmpty) {
      try {
        final uploadedVideo = await _videos.upload(draft.videoPaths.single);
        if (uploadedVideo.id.isEmpty) {
          throw StateError('Video response has no ID.');
        }
        final processedVideo = await _videos.waitUntilProcessed(
          uploadedVideo.id,
        );
        await _videos.tagProduct(processedVideo.id, product.id);
      } on Object catch (error) {
        throw ProductVideoAttachmentException(product: product, cause: error);
      }
    }
    return product;
  }

  ProductCategory _category(String categoryId) {
    final categoryCode = switch (categoryId) {
      'electronics' => 'ELECTRONICS',
      'vehicles' || 'transport' => 'TRANSPORT',
      'real-estate' => 'REAL_ESTATE',
      'home-appliances' => 'HOME_APPLIANCES',
      'special-occasion-clothing' => 'SPECIAL_OCCASION',
      'cosmetics' => 'COSMETICS',
      _ => categoryId,
    };
    final category = ProductCategory.fromCode(categoryCode);
    if (category == null || category == ProductCategory.unknown) {
      throw StateError('Unsupported product category.');
    }
    return category;
  }

  ProductCondition _condition(ListingCondition condition) =>
      switch (condition) {
        ListingCondition.newItem => ProductCondition.newCondition,
        ListingCondition.used => ProductCondition.used,
      };

  bool _isRemoteUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');
}
