import '../../core/network/media_url.dart';
import '../enums/product_category.dart';

import '../../core/utils/currency_formatter.dart';

class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.city,
    required this.imageUrl,
    this.category,
    this.categoryLabel,
    this.sellerId,
    this.sellerName,
    this.sellerAvatarUrl,
    this.status,
    this.imageUrls = const [],
  });

  final String id;
  final String title;
  final double price;
  final String currency;
  final String city;
  final String? imageUrl;
  final ProductCategory? category;
  final String? categoryLabel;
  final String? sellerId;
  final String? sellerName;
  final String? sellerAvatarUrl;
  final String? status;
  final List<String> imageUrls;

  factory ProductSummary.fromJson(
    Map<String, dynamic> json, {
    String? mediaOrigin,
  }) => ProductSummary(
    id: '${json['id'] ?? ''}',
    title: '${json['title'] ?? ''}',
    price: json['price'] is num ? (json['price'] as num).toDouble() : 0,
    currency: '${json['currency'] ?? fallbackCurrencyCode}',
    city: '${json['city'] ?? ''}',
    imageUrl: _resolveMedia(json['imageUrl'] as String?, mediaOrigin),
    category: json['category'] == null
        ? null
        : ProductCategory.fromCode(json['category'] as String?),
    categoryLabel: json['categoryLabel'] as String?,
    sellerId: json['sellerId']?.toString(),
    sellerName: json['sellerName'] as String?,
    sellerAvatarUrl: _resolveMedia(
      json['sellerAvatarUrl'] as String?,
      mediaOrigin,
    ),
    status: json['status'] as String?,
    imageUrls: json['imageUrls'] is List
        ? (json['imageUrls'] as List)
              .whereType<String>()
              .map((url) => _resolveMedia(url, mediaOrigin))
              .nonNulls
              .toList()
        : const [],
  );

  static String? _resolveMedia(String? value, String? origin) =>
      origin == null ? value : resolveMediaUrl(value, origin: origin);
}
