import 'package:vidsell/features/discover/models/product_listing.dart';
import 'package:vidsell/features/home/models/home_listing.dart';

HomeListing toHomeListing(ProductListing listing) {
  return HomeListing(
    id: listing.id ?? listing.title,
    imagePath: listing.imagePath,
    sellerName: listing.sellerName.isNotEmpty ? listing.sellerName : 'Satıcı',
    sellerHandle: '',
    sellerAvatar: listing.sellerAvatar,
    price: listing.price,
    title: listing.title,
    shareLink: '',
    videoUrl: listing.videoUrl,
    categoryId: listing.categoryId,
    sellerId: listing.sellerId,
    businessId: listing.businessId,
    phoneNumber: listing.phoneNumber,
    city: listing.location,
    cityId: listing.cityId,
    subcategoryId: listing.subcategoryId,
    priceAmount: listing.priceValue,
    status: listing.status,
    createdAt: listing.createdAt,
    latitude: listing.latitude,
    longitude: listing.longitude,
    isVip: listing.isVip,
    brand: listing.brand,
    updatedAt: listing.updatedAt?.toIso8601String() ?? '',
  );
}

ProductListing toProductListing(HomeListing listing) {
  return ProductListing(
    id: listing.id,
    imagePath: listing.imagePath,
    price: listing.price,
    title: listing.title,
    timeAgo: _timeAgo(listing),
    location: listing.city,
    brand: listing.brand,
    latitude: listing.latitude,
    longitude: listing.longitude,
    priceValue: listing.priceAmount,
    isVip: listing.isVip,
    isFavorite: listing.isFavorite,
    phoneNumber: listing.phoneNumber,
    videoUrl: listing.videoUrl,
    sellerName: listing.sellerName,
    sellerId: listing.sellerId,
    sellerAvatar: listing.sellerAvatar,
    businessId: listing.businessId,
    categoryId: listing.categoryId,
    subcategoryId: listing.subcategoryId,
    cityId: listing.cityId,
    status: listing.status,
    createdAt: listing.createdAt,
  );
}

String _timeAgo(HomeListing listing) {
  final date =
      (listing.updatedAt.isNotEmpty
          ? DateTime.tryParse(listing.updatedAt)
          : null) ??
      listing.createdAt;
  if (date == null) return '';

  final age = DateTime.now().difference(date);
  if (age.inDays > 0) return '${age.inDays} days';
  return '${age.inHours.clamp(1, 9999).toInt()} hours';
}
