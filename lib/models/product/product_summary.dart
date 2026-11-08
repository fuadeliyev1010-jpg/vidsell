import '../enums/product_category.dart';

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
  final String? status;
  final List<String> imageUrls;

  factory ProductSummary.fromJson(Map<String, dynamic> json) => ProductSummary(
    id: '${json['id'] ?? ''}',
    title: '${json['title'] ?? ''}',
    price: json['price'] is num ? (json['price'] as num).toDouble() : 0,
    currency: '${json['currency'] ?? 'TRY'}',
    city: '${json['city'] ?? ''}',
    imageUrl: json['imageUrl'] as String?,
    category: json['category'] == null
        ? null
        : ProductCategory.fromCode(json['category'] as String?),
    categoryLabel: json['categoryLabel'] as String?,
    sellerId: json['sellerId']?.toString(),
    sellerName: json['sellerName'] as String?,
    status: json['status'] as String?,
    imageUrls: json['imageUrls'] is List
        ? (json['imageUrls'] as List).whereType<String>().toList()
        : const [],
  );
}
