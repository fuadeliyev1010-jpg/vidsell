import '../enums/product_category.dart';
import '../../core/network/media_url.dart';

class Favorite {
  const Favorite({
    required this.id,
    required this.title,
    required this.price,
    required this.city,
    required this.imageUrl,
    required this.sellerId,
    required this.favoritedAt,
    this.category,
  });

  final String id;
  final String title;
  final double price;
  final String city;
  final ProductCategory? category;
  final String? imageUrl;
  final String sellerId;
  final DateTime? favoritedAt;

  factory Favorite.fromJson(Map<String, dynamic> json, {String? mediaOrigin}) {
    final product = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'] as Map)
        : json['listing'] is Map
        ? Map<String, dynamic>.from(json['listing'] as Map)
        : json;
    return Favorite(
      id: '${json['listingId'] ?? product['id'] ?? ''}',
      title: '${product['title'] ?? ''}',
      price: _double(product['price']),
      city: '${product['city'] ?? product['cityName'] ?? ''}',
      imageUrl: _resolveMedia(
        product['imageUrl'] as String? ??
            product['thumbnailUrl'] as String? ??
            _firstImage(product['imageUrls']),
        mediaOrigin,
      ),
      sellerId: '${product['sellerId'] ?? ''}',
      favoritedAt: DateTime.tryParse(
        '${json['favoritedAt'] ?? json['createdAt'] ?? ''}',
      ),
      category: ProductCategory.fromCode(
        product['category']?.toString().toUpperCase(),
      ),
    );
  }

  static double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static String? _firstImage(dynamic value) =>
      value is List && value.isNotEmpty && value.first is String
      ? value.first as String
      : null;

  static String? _resolveMedia(String? value, String? origin) =>
      origin == null ? value : resolveMediaUrl(value, origin: origin);
}
