import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

class MockUserListingRepository implements UserListingRepository {
  final List<Product> _listings = [];

  void addListing(Product listing) {
    _listings.removeWhere((item) => item.id == listing.id);
    _listings.add(listing);
  }

  @override
  Future<List<Product>> fetchMyListings({ProductStatus? status}) async {
    if (status == null) return List.unmodifiable(_listings);
    return _listings.where((listing) => listing.status == status).toList();
  }

  @override
  Future<void> updateListingStatus(
    String listingId,
    ProductStatus status,
  ) async {
    final index = _listings.indexWhere((listing) => listing.id == listingId);
    if (index == -1) return;
    final listing = _listings[index];
    _listings[index] = Product(
      id: listing.id,
      title: listing.title,
      price: listing.price,
      originalPrice: listing.originalPrice,
      discountPercent: listing.discountPercent,
      currency: listing.currency,
      description: listing.description,
      category: listing.category,
      city: listing.city,
      condition: listing.condition,
      status: status,
      promotionType: listing.promotionType,
      imageUrls: listing.imageUrls,
      averageRating: listing.averageRating,
      reviewCount: listing.reviewCount,
      viewCount: listing.viewCount,
      shareCount: listing.shareCount,
      distanceKm: listing.distanceKm,
      sellerId: listing.sellerId,
      sellerName: listing.sellerName,
      sellerHandle: listing.sellerHandle,
      sellerAvatarUrl: listing.sellerAvatarUrl,
      sellerPhone: listing.sellerPhone,
      businessId: listing.businessId,
      categoryId: listing.categoryId,
      subcategoryId: listing.subcategoryId,
      subcategoryName: listing.subcategoryName,
      cityId: listing.cityId,
      shareUrl: listing.shareUrl,
      listingNumber: listing.listingNumber,
      isFavorite: listing.isFavorite,
      isVip: listing.isVip,
      latitude: listing.latitude,
      longitude: listing.longitude,
      brand: listing.brand,
      model: listing.model,
      color: listing.color,
      storage: listing.storage,
      simCard: listing.simCard,
      deliveryLabel: listing.deliveryLabel,
      deliveryType: listing.deliveryType,
      sellerType: listing.sellerType,
      createdAt: listing.createdAt,
      updatedAt: listing.updatedAt,
    );
  }

  @override
  Future<void> deleteListing(String listingId) async {
    _listings.removeWhere((listing) => listing.id == listingId);
  }
}
