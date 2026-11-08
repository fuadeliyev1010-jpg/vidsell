import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

class ProductLegacyAdapter {
  const ProductLegacyAdapter._();

  static Product fromJson(Map<String, dynamic> json) => Product.fromJson(json);

  static Listing toListing(Product product) => Listing(
    id: product.id,
    title: product.title,
    price: product.price,
    currency: product.currency,
    description: product.description,
    status: _listingStatus(product.status),
    sellerId: product.sellerId ?? '',
    businessId: product.businessId,
    categoryId: product.categoryId ?? '',
    subcategoryId: product.subcategoryId ?? '',
    cityId: product.cityId ?? '',
    cityName: product.city ?? '',
    subcategoryName: product.subcategoryLabel ?? product.subcategoryName ?? '',
    sellerName: product.sellerName ?? '',
    sellerHandle: product.sellerHandle ?? '',
    sellerAvatarUrl: product.sellerAvatarUrl,
    sellerPhone: product.sellerPhone,
    brand: product.brand,
    model: product.model,
    color: product.color,
    storage: product.storage,
    simCard: product.simCard,
    condition: product.conditionDisplay,
    delivery: product.deliveryTypeDisplay,
    latitude: product.latitude,
    longitude: product.longitude,
    media: [
      for (final url in product.imageUrls)
        ListingMedia(url: url, type: ListingMediaType.image),
    ],
    shareUrl: product.shareUrl ?? '',
    listingNumber: product.listingNumber ?? '',
    viewCount: product.viewCount,
    isFavorite: product.isFavorite,
    isVip: product.isVip,
    createdAt: product.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: product.updatedAt,
  );

  static ListingStatus _listingStatus(ProductStatus? status) =>
      switch (status) {
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
