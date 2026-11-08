import 'package:vidsell/features/new_listing/models/created_listing.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/listing_repository.dart';
import 'package:vidsell/models/enums/product_condition.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

class MockListingRepository implements ListingRepository {
  MockListingRepository({this.onListingCreated});

  final void Function(Product)? onListingCreated;
  int _nextId = 1;

  @override
  Future<CreatedListing> createListing(ListingDraft draft) async {
    if (draft.imagePaths.isEmpty && draft.videoPaths.isEmpty) {
      throw StateError('missing_media');
    }

    final id = 'mock-listing-${_nextId++}';
    final media = <ListingMedia>[
      for (var index = 0; index < draft.imagePaths.length; index++)
        ListingMedia(
          url: draft.imagePaths[index],
          type: ListingMediaType.image,
          sortOrder: index,
        ),
      for (var index = 0; index < draft.videoPaths.length; index++)
        ListingMedia(
          url: draft.videoPaths[index],
          type: ListingMediaType.video,
          sortOrder: draft.imagePaths.length + index,
          thumbnailUrl: index < draft.videoCoverPaths.length
              ? draft.videoCoverPaths[index]
              : null,
        ),
    ];
    onListingCreated?.call(
      Product(
        id: id,
        title: draft.title,
        price: draft.price,
        currency: draft.currency,
        description: draft.description,
        status: ProductStatus.underReview,
        sellerId: 'mock-user',
        categoryId: draft.categoryId,
        subcategoryId: draft.subcategoryId,
        cityId: draft.cityId,
        city: draft.city,
        sellerName: draft.sellerName,
        sellerPhone: draft.phone,
        brand: draft.brand,
        model: draft.model,
        condition: ProductCondition.fromCode(
          draft.condition.name.toUpperCase(),
        ),
        deliveryLabel: draft.delivery.name,
        imageUrls: [for (final item in media) item.url],
        shareUrl: 'https://vidsell.az/listing/$id',
        createdAt: DateTime.now(),
      ),
    );
    return CreatedListing(
      id: id,
      status: ListingStatus.pendingModeration,
      shareUrl: 'https://vidsell.az/listing/$id',
    );
  }
}
