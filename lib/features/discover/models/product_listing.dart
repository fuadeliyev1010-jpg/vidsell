import 'package:vidsell/features/new_listing/models/listing.dart';

class ProductListing {
  final String? id;
  final String imagePath;
  final String price;
  final String title;
  final String timeAgo;
  final String location;
  final String brand;
  final double mapX; // 0.0 - 1.0 relative position on map
  final double mapY; // 0.0 - 1.0 relative position on map
  final double? latitude;
  final double? longitude;
  final double? priceValue;
  final bool isVip;
  final bool isFavorite;
  final String? phoneNumber;
  final String? videoUrl;
  final String sellerName;
  final String? sellerId;
  final String? sellerAvatar;
  final String? businessId;
  final String? categoryId;
  final String? subcategoryId;
  final String? cityId;
  final ListingStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductListing({
    this.id,
    required this.imagePath,
    required this.price,
    required this.title,
    required this.timeAgo,
    this.location = 'İstanbul',
    this.brand = 'Apple iPhone',
    this.mapX = 0.5,
    this.mapY = 0.5,
    this.latitude,
    this.longitude,
    this.priceValue,
    this.isVip = true,
    this.isFavorite = false,
    this.phoneNumber,
    this.videoUrl,
    this.sellerName = '',
    this.sellerId,
    this.sellerAvatar,
    this.businessId,
    this.categoryId,
    this.subcategoryId,
    this.cityId,
    this.status = ListingStatus.unknown,
    this.createdAt,
    this.updatedAt,
  });

  ProductListing copyWith({
    String? id,
    String? imagePath,
    String? price,
    String? title,
    String? timeAgo,
    String? location,
    String? brand,
    double? mapX,
    double? mapY,
    double? latitude,
    double? longitude,
    double? priceValue,
    bool? isVip,
    bool? isFavorite,
    String? phoneNumber,
    String? videoUrl,
    String? sellerName,
    String? sellerId,
    String? sellerAvatar,
    String? businessId,
    String? categoryId,
    String? subcategoryId,
    String? cityId,
    ListingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductListing(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      title: title ?? this.title,
      timeAgo: timeAgo ?? this.timeAgo,
      location: location ?? this.location,
      brand: brand ?? this.brand,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      priceValue: priceValue ?? this.priceValue,
      isVip: isVip ?? this.isVip,
      isFavorite: isFavorite ?? this.isFavorite,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      videoUrl: videoUrl ?? this.videoUrl,
      sellerName: sellerName ?? this.sellerName,
      sellerId: sellerId ?? this.sellerId,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      cityId: cityId ?? this.cityId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
