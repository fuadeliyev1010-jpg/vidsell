import '../../core/utils/currency_formatter.dart';
import '../enums/product_category.dart';
import '../enums/product_condition.dart';
import '../enums/product_subcategory.dart';

class ProductRequest {
  const ProductRequest({
    required this.title,
    required this.price,
    required this.category,
    this.description,
    this.currency = fallbackCurrencyCode,
    this.subcategory,
    this.storage,
    this.brand,
    this.modelName,
    this.color,
    this.city,
    this.condition,
    this.imageUrls = const [],
  });

  final String title;
  final double price;
  final String? description;
  final String currency;
  final ProductCategory category;
  final ProductSubcategory? subcategory;
  final String? storage;
  final String? brand;
  final String? modelName;
  final String? color;
  final String? city;
  final ProductCondition? condition;
  final List<String> imageUrls;

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'price': price,
    'currency': currency,
    'category': category.code,
    if (subcategory != null && subcategory!.code != 'UNKNOWN')
      'subcategory': subcategory!.code,
    if (storage != null) 'storage': storage,
    if (brand != null) 'brand': brand,
    if (modelName != null) 'modelName': modelName,
    if (color != null) 'color': color,
    if (city != null) 'city': city,
    if (condition != null) 'condition': condition!.code,
    'imageUrls': imageUrls,
  };
}
