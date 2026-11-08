import 'package:vidsell/features/new_listing/models/listing.dart';

class HomeListing {
  final String id;
  final String imagePath;
  final String sellerName;
  final String sellerHandle;
  final String? sellerAvatar;
  final String price;
  final String title;
  final String shareLink;
  final String? videoUrl;
  final String? categoryId;
  final String? sellerId;
  final String? businessId;
  final String? phoneNumber;
  final String description;
  final String city;
  final String? cityId;
  final String categoryName;
  final String? subcategoryId;
  final String subcategoryName;
  final String brand;
  final String model;
  final String color;
  final String storage;
  final String simCard;
  final String condition;
  final String delivery;
  final double? latitude;
  final double? longitude;
  final String listingNumber;
  final int? viewCount;
  final String updatedAt;
  final bool isFavorite;
  final bool isVip;
  final double? priceAmount;
  final String currency;
  final ListingStatus status;
  final DateTime? createdAt;

  const HomeListing({
    required this.id,
    this.imagePath = '',
    required this.sellerName,
    required this.sellerHandle,
    this.sellerAvatar,
    required this.price,
    required this.title,
    required this.shareLink,
    this.videoUrl,
    this.categoryId,
    this.sellerId,
    this.businessId,
    this.phoneNumber,
    this.description = '',
    this.city = 'İstanbul',
    this.cityId,
    this.categoryName = '',
    this.subcategoryId,
    this.subcategoryName = '',
    this.brand = '',
    this.model = '',
    this.color = '',
    this.storage = '',
    this.simCard = '',
    this.condition = '',
    this.delivery = '',
    this.latitude,
    this.longitude,
    this.listingNumber = '',
    this.viewCount,
    this.updatedAt = '',
    this.isFavorite = false,
    this.isVip = false,
    this.priceAmount,
    this.currency = 'AZN',
    this.status = ListingStatus.unknown,
    this.createdAt,
  });

  factory HomeListing.fromJson(Map<String, dynamic> json) =>
      HomeListing.fromListing(Listing.fromJson(json));

  factory HomeListing.fromListing(Listing listing) {
    final image = _firstMedia(
      listing.media,
      (item) => item.type != ListingMediaType.video,
    );
    final video = _firstMedia(
      listing.media,
      (item) => item.type == ListingMediaType.video,
    );
    return HomeListing(
      id: listing.id,
      imagePath: image?.url ?? video?.thumbnailUrl ?? '',
      sellerName: listing.sellerName,
      sellerHandle: listing.sellerHandle,
      sellerAvatar: listing.sellerAvatarUrl,
      price:
          '${listing.price % 1 == 0 ? listing.price.toInt() : listing.price} '
                  '${listing.currency}'
              .trim(),
      title: listing.title,
      shareLink: listing.shareUrl,
      videoUrl: video?.url,
      categoryId: listing.categoryId,
      sellerId: listing.sellerId,
      businessId: listing.businessId,
      phoneNumber: listing.sellerPhone,
      description: listing.description,
      city: listing.cityName.isEmpty ? 'İstanbul' : listing.cityName,
      cityId: listing.cityId,
      categoryName: listing.categoryName,
      subcategoryId: listing.subcategoryId,
      subcategoryName: listing.subcategoryName,
      brand: listing.brand,
      model: listing.model,
      color: listing.color,
      storage: listing.storage,
      simCard: listing.simCard,
      condition: listing.condition,
      delivery: listing.delivery,
      latitude: listing.latitude,
      longitude: listing.longitude,
      listingNumber: listing.listingNumber,
      viewCount: listing.viewCount,
      updatedAt: listing.updatedAt?.toIso8601String() ?? '',
      isFavorite: listing.isFavorite,
      isVip: listing.isVip,
      priceAmount: listing.price,
      currency: listing.currency,
      status: listing.status,
      createdAt: listing.createdAt,
    );
  }

  HomeListing copyWith({
    String? id,
    String? imagePath,
    String? cityId,
    String? subcategoryId,
    String? businessId,
    double? priceAmount,
    String? currency,
    ListingStatus? status,
    DateTime? createdAt,
    String? videoUrl,
    String? sellerAvatar,
    String? phoneNumber,
    String? description,
    String? city,
    String? categoryName,
    String? subcategoryName,
    String? brand,
    String? model,
    String? color,
    String? storage,
    String? simCard,
    String? condition,
    String? delivery,
    double? latitude,
    double? longitude,
    String? listingNumber,
    int? viewCount,
    String? updatedAt,
    bool? isFavorite,
    bool? isVip,
  }) {
    return HomeListing(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      sellerName: sellerName,
      sellerHandle: sellerHandle,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      price: price,
      title: title,
      shareLink: shareLink,
      videoUrl: videoUrl ?? this.videoUrl,
      categoryId: categoryId,
      sellerId: sellerId,
      businessId: businessId ?? this.businessId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      city: city ?? this.city,
      cityId: cityId ?? this.cityId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      storage: storage ?? this.storage,
      simCard: simCard ?? this.simCard,
      condition: condition ?? this.condition,
      delivery: delivery ?? this.delivery,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      listingNumber: listingNumber ?? this.listingNumber,
      viewCount: viewCount ?? this.viewCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isVip: isVip ?? this.isVip,
      priceAmount: priceAmount ?? this.priceAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isNetworkMedia =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  bool get hasVideo => videoUrl?.trim().isNotEmpty ?? false;

  static ListingMedia? _firstMedia(
    List<ListingMedia> media,
    bool Function(ListingMedia) test,
  ) {
    for (final item in media) {
      if (test(item)) return item;
    }
    return null;
  }
}
