import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/listing_repository.dart';
import 'package:vidsell/models/enums/product_category.dart';
import 'package:vidsell/models/enums/product_condition.dart';
import 'package:vidsell/models/enums/product_subcategory.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

class MockListingRepository implements ListingRepository {
  MockListingRepository({this.onListingCreated});

  final void Function(Product)? onListingCreated;
  int _nextId = 1;

  @override
  Future<List<String>> uploadImages(List<String> localPaths) async =>
      List.unmodifiable(localPaths);

  @override
  Future<Product> createListing(ListingDraft draft) async {
    if (draft.imagePaths.isEmpty && draft.videoPaths.isEmpty) {
      throw StateError('missing_media');
    }

    final id = 'mock-listing-${_nextId++}';
    final imageUrls = await uploadImages(draft.imagePaths);
    final product = Product(
      id: id,
      title: draft.title,
      price: draft.price,
      currency: draft.currency,
      description: draft.description,
      category: _category(draft.categoryId),
      categoryLabel: draft.categoryName,
      subcategory: ProductSubcategory.fromCode(draft.subcategoryId),
      subcategoryName: draft.subcategoryName,
      status: ProductStatus.active,
      sellerId: 'mock-user',
      categoryId: draft.categoryId,
      subcategoryId: draft.subcategoryId,
      cityId: draft.cityId,
      city: draft.city,
      sellerName: draft.sellerName,
      sellerPhone: draft.phone,
      brand: draft.brand,
      model: draft.model,
      condition: ProductCondition.fromCode(draft.condition.name.toUpperCase()),
      deliveryLabel: draft.delivery?.name ?? '',
      imageUrls: imageUrls,
      shareUrl: 'https://vidsell.az/listing/$id',
      createdAt: DateTime.now(),
    );
    onListingCreated?.call(product);
    return product;
  }

  ProductCategory _category(String categoryId) => switch (categoryId) {
    'electronics' => ProductCategory.electronics,
    'vehicles' || 'transport' => ProductCategory.transport,
    'real-estate' => ProductCategory.realEstate,
    'home-appliances' => ProductCategory.homeAppliances,
    'special-occasion-clothing' => ProductCategory.specialOccasion,
    'cosmetics' => ProductCategory.cosmetics,
    _ => ProductCategory.unknown,
  };
}
