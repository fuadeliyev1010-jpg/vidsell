import 'dart:convert';

import '../../core/utils/currency_formatter.dart';
import '../enums/delivery_type.dart';
import '../enums/product_category.dart';
import '../enums/product_condition.dart';
import '../enums/product_status.dart';
import '../enums/product_subcategory.dart';
import '../enums/promotion_type.dart';
import '../enums/seller_type.dart';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.currency = fallbackCurrencyCode,
    this.description = '',
    this.category,
    this.categoryLabel,
    this.subcategory,
    this.city,
    this.condition,
    this.conditionLabel,
    this.status,
    this.statusLabel,
    this.promotionType,
    this.promotionTypeLabel,
    this.imageUrls = const [],
    this.averageRating,
    this.reviewCount = 0,
    this.viewCount = 0,
    this.shareCount = 0,
    this.distanceKm,
    this.sellerId,
    this.sellerName,
    this.sellerHandle,
    this.sellerAvatarUrl,
    this.sellerPhone,
    this.businessId,
    this.categoryId,
    this.subcategoryId,
    this.subcategoryLabel,
    this.subcategoryName,
    this.cityId,
    this.shareUrl,
    this.listingNumber,
    this.isFavorite = false,
    this.isVip = false,
    this.latitude,
    this.longitude,
    this.brand = '',
    this.model = '',
    this.color = '',
    this.storage = '',
    this.simCard = '',
    this.deliveryLabel = '',
    this.deliveryType,
    this.deliveryTypeLabel,
    this.sellerType,
    this.sellerTypeLabel,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final double price;
  final double? originalPrice;
  final double? discountPercent;
  final String currency;
  final String description;
  final ProductCategory? category;
  final String? categoryLabel;
  final ProductSubcategory? subcategory;
  final String? city;
  final ProductCondition? condition;
  final String? conditionLabel;
  final ProductStatus? status;
  final String? statusLabel;
  final PromotionType? promotionType;
  final String? promotionTypeLabel;
  final List<String> imageUrls;
  final double? averageRating;
  final int reviewCount;
  final int viewCount;
  final int shareCount;
  final double? distanceKm;
  final String? sellerId;
  final String? sellerName;
  final String? sellerHandle;
  final String? sellerAvatarUrl;
  final String? sellerPhone;
  final String? businessId;
  final String? categoryId;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? subcategoryLabel;
  final String? cityId;
  final String? shareUrl;
  final String? listingNumber;
  final bool isFavorite;
  final bool isVip;
  final double? latitude;
  final double? longitude;
  final String brand;
  final String model;
  final String color;
  final String storage;
  final String simCard;
  final String deliveryLabel;
  final DeliveryType? deliveryType;
  final String? deliveryTypeLabel;
  final SellerType? sellerType;
  final String? sellerTypeLabel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  List<String> get mediaUrls => imageUrls;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: '${json['id'] ?? json['productId'] ?? ''}',
    title: '${json['title'] ?? ''}',
    price: _double(json['price']),
    originalPrice: _doubleOrNull(json['originalPrice']),
    discountPercent: _doubleOrNull(json['discountPercent']),
    currency: '${json['currency'] ?? fallbackCurrencyCode}',
    description: '${json['description'] ?? ''}',
    category: _category(json['category']),
    categoryLabel: json['categoryLabel'] as String?,
    subcategory: json['subcategory'] == null
        ? null
        : ProductSubcategory.fromCode(json['subcategory']),
    city: json['city'] as String?,
    condition: _condition(json['condition']),
    conditionLabel: json['conditionLabel'] as String?,
    status: _status(json['status']),
    statusLabel: json['statusLabel'] as String?,
    promotionType: json['promotionType'] == null
        ? null
        : PromotionType.fromCode(
            json['promotionType']?.toString().toUpperCase(),
          ),
    promotionTypeLabel: json['promotionTypeLabel'] as String?,
    imageUrls: _strings(
      json['imageUrls'] ??
          [if (json['imageUrl'] is String) json['imageUrl'] as String],
    ),
    averageRating: _doubleOrNull(json['averageRating']),
    reviewCount: _int(json['reviewCount']),
    viewCount: _int(json['viewCount']),
    shareCount: _int(json['shareCount']),
    distanceKm: _doubleOrNull(json['distanceKm']),
    sellerId: json['sellerId'] as String?,
    sellerName:
        json['sellerName'] as String? ?? json['sellerFullName'] as String?,
    sellerHandle: json['sellerHandle'] as String?,
    sellerAvatarUrl:
        json['sellerAvatarUrl'] as String? ?? json['sellerAvatar'] as String?,
    businessId: json['businessId']?.toString(),
    categoryId: json['categoryId']?.toString(),
    subcategoryId: json['subcategoryId']?.toString(),
    subcategoryName: json['subcategoryName'] as String?,
    subcategoryLabel: json['subcategoryLabel'] as String?,
    cityId: json['cityId']?.toString(),
    shareUrl: json['shareUrl'] as String? ?? json['shareLink'] as String?,
    listingNumber: json['listingNumber']?.toString(),
    isFavorite: json['isFavorite'] == true,
    isVip: json['isVip'] == true || json['isPremium'] == true,
    latitude: _doubleOrNull(json['latitude']),
    longitude: _doubleOrNull(json['longitude']),
    brand: json['brand'] as String? ?? '',
    model: json['model'] as String? ?? json['modelName'] as String? ?? '',
    color: json['color'] as String? ?? '',
    storage: json['storage'] as String? ?? '',
    simCard: json['simCard'] as String? ?? '',
    deliveryLabel: json['delivery'] as String? ?? '',
    deliveryType: json['deliveryType'] == null
        ? null
        : DeliveryType.fromCode(json['deliveryType']?.toString().toUpperCase()),
    deliveryTypeLabel: json['deliveryTypeLabel'] as String?,
    sellerType: json['sellerType'] == null
        ? null
        : SellerType.fromCode(json['sellerType']?.toString().toUpperCase()),
    sellerTypeLabel: json['sellerTypeLabel'] as String?,
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    if (originalPrice != null) 'originalPrice': originalPrice,
    if (discountPercent != null) 'discountPercent': discountPercent,
    'currency': currency,
    'description': description,
    if (category != null) 'category': category!.code,
    if (categoryLabel != null) 'categoryLabel': categoryLabel,
    if (subcategory != null && subcategory!.code != 'UNKNOWN')
      'subcategory': subcategory!.code,
    if (city != null) 'city': city,
    if (condition != null) 'condition': condition!.code,
    if (conditionLabel != null) 'conditionLabel': conditionLabel,
    if (status != null) 'status': status!.code,
    if (statusLabel != null) 'statusLabel': statusLabel,
    if (promotionType != null) 'promotionType': promotionType!.code,
    if (promotionTypeLabel != null) 'promotionTypeLabel': promotionTypeLabel,
    'imageUrls': imageUrls,
    if (averageRating != null) 'averageRating': averageRating,
    'reviewCount': reviewCount,
    'viewCount': viewCount,
    'shareCount': shareCount,
    if (distanceKm != null) 'distanceKm': distanceKm,
    if (sellerId != null) 'sellerId': sellerId,
    if (sellerName != null) 'sellerName': sellerName,
    if (sellerHandle != null) 'sellerHandle': sellerHandle,
    if (sellerAvatarUrl != null) 'sellerAvatarUrl': sellerAvatarUrl,
    if (sellerPhone != null) 'sellerPhone': sellerPhone,
    if (businessId != null) 'businessId': businessId,
    if (categoryId != null) 'categoryId': categoryId,
    if (subcategoryId != null) 'subcategoryId': subcategoryId,
    if (subcategoryName != null) 'subcategoryName': subcategoryName,
    if (subcategoryLabel != null) 'subcategoryLabel': subcategoryLabel,
    if (cityId != null) 'cityId': cityId,
    if (shareUrl != null) 'shareUrl': shareUrl,
    if (listingNumber != null) 'listingNumber': listingNumber,
    'isFavorite': isFavorite,
    'isVip': isVip,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'brand': brand,
    'model': model,
    'color': color,
    'storage': storage,
    'simCard': simCard,
    if (deliveryLabel.isNotEmpty) 'delivery': deliveryLabel,
    if (deliveryType != null) 'deliveryType': deliveryType!.code,
    if (deliveryTypeLabel != null) 'deliveryTypeLabel': deliveryTypeLabel,
    if (sellerType != null) 'sellerType': sellerType!.code,
    if (sellerTypeLabel != null) 'sellerTypeLabel': sellerTypeLabel,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  static double _double(dynamic value) => _doubleOrNull(value) ?? 0;
  static double? _doubleOrNull(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value');
  static int _int(dynamic value) =>
      value is int ? value : int.tryParse('$value') ?? 0;
  static List<String> _strings(dynamic value) {
    final decoded = switch (value) {
      String raw => _decodeStringOrUrl(raw),
      List<dynamic> list => list,
      _ => const <dynamic>[],
    };
    return decoded
        .map(
          (item) => item is String
              ? item
              : item is Map
              ? item['url']
              : null,
        )
        .whereType<String>()
        .toList(growable: false);
  }

  static List<dynamic> _decodeStringOrUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) return decoded;
    } on FormatException {
      return [value];
    }
    return [value];
  }

  static ProductCategory? _category(dynamic value) {
    if (value == null) return null;
    final normalized = value?.toString().toUpperCase();
    return ProductCategory.fromCode(switch (normalized) {
      'VEHICLES' => 'TRANSPORT',
      'HOME-APPLIANCES' => 'HOME_APPLIANCES',
      'SPECIAL-OCCASION-CLOTHING' => 'SPECIAL_OCCASION',
      _ => normalized,
    });
  }

  static ProductCondition? _condition(dynamic value) {
    if (value == null) return null;
    final normalized = value?.toString().toUpperCase();
    return ProductCondition.fromCode(
      normalized == 'NEWITEM' ? 'NEW' : normalized,
    );
  }

  static ProductStatus? _status(dynamic value) {
    if (value == null) return null;
    final normalized = value?.toString().toUpperCase().replaceAll('-', '_');
    return ProductStatus.fromCode(switch (normalized) {
      'PENDING' || 'PENDING_MODERATION' || 'PENDING_REVIEW' => 'UNDER_REVIEW',
      'APPROVED' => 'ACTIVE',
      'PAUSED' || 'EXPIRED' => 'INACTIVE',
      'REMOVED' => 'DELETED',
      _ => normalized,
    });
  }
}

extension ProductUi on Product {
  String get categoryDisplay => categoryLabel ?? category?.code ?? '';

  String get subcategoryDisplay =>
      subcategoryLabel ??
      subcategoryName ??
      (subcategory == null ||
              (subcategory!.isUnknown && subcategory!.code == 'UNKNOWN')
          ? ''
          : subcategory!.code);

  String get conditionDisplay => conditionLabel ?? condition?.code ?? '';

  String get statusDisplay => statusLabel ?? status?.code ?? '';

  String get promotionDisplay =>
      promotionTypeLabel ?? promotionType?.code ?? '';

  String get sellerTypeDisplay => sellerTypeLabel ?? sellerType?.code ?? '';

  String get deliveryTypeDisplay =>
      deliveryTypeLabel ??
      (deliveryLabel.isNotEmpty ? deliveryLabel : deliveryType?.code ?? '');
}
