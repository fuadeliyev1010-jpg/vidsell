import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/models/video/feed_item.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

class ProductLegacyAdapter {
  const ProductLegacyAdapter._();

  static Product fromJson(Map<String, dynamic> json) => Product.fromJson(json);

  static Product fromHomeListing(HomeListing listing) => Product(
    id: listing.id,
    title: listing.title,
    price: listing.priceAmount ?? _priceValue(listing.price),
    currency: listing.currency.isEmpty
        ? _currencyFrom(listing.price)
        : listing.currency,
    description: listing.description,
    imageUrls: [
      if (listing.imagePath.isNotEmpty) listing.imagePath,
      if (listing.videoUrl?.isNotEmpty == true) listing.videoUrl!,
    ],
    city: listing.city,
    status: _productStatus(listing.status),
    cityId: listing.cityId,
    categoryId: listing.categoryId,
    subcategoryId: listing.subcategoryId,
    subcategoryName: listing.subcategoryName,
    sellerId: listing.sellerId,
    sellerName: listing.sellerName,
    sellerHandle: listing.sellerHandle,
    sellerAvatarUrl: listing.sellerAvatar,
    sellerPhone: listing.phoneNumber,
    businessId: listing.businessId,
    shareUrl: listing.shareLink,
    listingNumber: listing.listingNumber,
    viewCount: listing.viewCount ?? 0,
    isFavorite: listing.isFavorite,
    isVip: listing.isVip,
    latitude: listing.latitude,
    longitude: listing.longitude,
    brand: listing.brand,
    model: listing.model,
    color: listing.color,
    storage: listing.storage,
    simCard: listing.simCard,
    createdAt: listing.createdAt,
    updatedAt: DateTime.tryParse(listing.updatedAt),
  );

  static HomeListing toHomeListingFromFeedItem(FeedItem item) {
    final product = item.product;
    if (product == null) {
      return HomeListing(
        id: item.videoId,
        sellerName: item.ownerName ?? '',
        sellerHandle: '',
        title: '',
        price: '',
        shareLink: '',
        imagePath: item.thumbnailUrl ?? '',
        videoUrl: item.hlsUrl,
      );
    }
    return toHomeListing(product).copyWith(
      imagePath: item.thumbnailUrl ?? '',
      videoUrl: item.hlsUrl,
      sellerAvatar: item.ownerAvatarUrl ?? product.sellerAvatarUrl,
    );
  }

  static HomeListing toHomeListing(Product product) => HomeListing(
    id: product.id,
    imagePath: product.imageUrls.isEmpty ? '' : product.imageUrls.first,
    sellerName: product.sellerName ?? '',
    sellerHandle: product.sellerHandle ?? '',
    sellerAvatar: product.sellerAvatarUrl,
    price: CurrencyFormatter.formatPrice(product.price, product.currency),
    title: product.title,
    shareLink: product.shareUrl ?? '',
    categoryId: product.categoryId,
    sellerId: product.sellerId,
    businessId: product.businessId,
    phoneNumber: product.sellerPhone,
    description: product.description,
    city: product.city ?? '',
    cityId: product.cityId,
    categoryName: product.categoryDisplay,
    subcategoryId: product.subcategoryId,
    subcategoryName: product.subcategoryLabel ?? product.subcategoryName ?? '',
    brand: product.brand,
    model: product.model,
    color: product.color,
    storage: product.storage,
    simCard: product.simCard,
    condition: product.conditionDisplay,
    delivery: product.deliveryTypeDisplay,
    latitude: product.latitude,
    longitude: product.longitude,
    listingNumber: product.listingNumber ?? '',
    viewCount: product.viewCount,
    updatedAt: product.updatedAt?.toIso8601String() ?? '',
    isFavorite: product.isFavorite,
    isVip: product.isVip,
    priceAmount: product.price,
    currency: product.currency,
    status: _listingStatus(product.status),
    createdAt: product.createdAt,
  );

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

  static ProductStatus? _productStatus(ListingStatus status) =>
      switch (status) {
        ListingStatus.active => ProductStatus.active,
        ListingStatus.sold => ProductStatus.sold,
        ListingStatus.pendingModeration => ProductStatus.underReview,
        ListingStatus.inactive => ProductStatus.inactive,
        ListingStatus.rejected => ProductStatus.rejected,
        ListingStatus.pendingPayment => ProductStatus.pendingPayment,
        ListingStatus.deleted => ProductStatus.deleted,
        _ => null,
      };

  static double _priceValue(String price) {
    final match = RegExp(r'^([\d.,]+)').firstMatch(price.trim());
    if (match == null) return 0;
    var amount = match.group(1)!;
    if (amount.contains('.') && amount.contains(',')) {
      amount = amount.replaceAll(',', '');
    } else if (amount.contains(',')) {
      amount = amount.replaceAll(',', '.');
    }
    return double.tryParse(amount) ?? 0;
  }

  static String _currencyFrom(String price) {
    final trimmed = price.trim();
    final match = RegExp(r'^[\d.,]+\s*(.*)$').firstMatch(trimmed);
    final currency = match?.group(1)?.trim();
    return currency == null || currency.isEmpty
        ? fallbackCurrencyCode
        : currency;
  }
}
