import '../enums/delivery_type.dart';
import '../enums/product_category.dart';
import '../enums/product_condition.dart';
import '../enums/seller_type.dart';
import '../enums/product_subcategory.dart';

class ProductRequest {
  const ProductRequest({
    required this.title,
    required this.price,
    this.description,
    this.category,
    this.subcategory,
    this.condition,
    this.deliveryType,
    this.imageUrls = const [],
    this.categoryId,
    this.subcategoryId,
    this.cityId,
    this.city,
    this.brand = '',
    this.model = '',
    this.modelName,
    this.currency = 'TRY',
    this.contact,
    this.contactMethod,
    this.sellerType,
  });

  final String title;
  final double price;
  final String? description;
  final ProductCategory? category;
  final ProductSubcategory? subcategory;
  final ProductCondition? condition;
  final DeliveryType? deliveryType;
  final List<String> imageUrls;
  final String? categoryId;
  final String? subcategoryId;
  final String? cityId;
  final String? city;
  final String brand;
  final String model;
  final String? modelName;
  final String currency;
  final Map<String, dynamic>? contact;
  final String? contactMethod;
  final SellerType? sellerType;

  Map<String, dynamic> toJson() => {
    'title': title,
    'price': price,
    'currency': currency,
    if (description != null) 'description': description,
    if (category != null) 'category': category!.code,
    if (subcategory != null && subcategory!.code != 'UNKNOWN')
      'subcategory': subcategory!.code,
    if (condition != null) 'condition': condition!.code,
    if (deliveryType != null) 'deliveryType': deliveryType!.code,
    'imageUrls': imageUrls,
    if (categoryId != null) 'categoryId': categoryId,
    if (subcategoryId != null) 'subcategoryId': subcategoryId,
    if (cityId != null) 'cityId': cityId,
    if (city != null) 'city': city,
    if (brand.isNotEmpty) 'brand': brand,
    if (model.isNotEmpty) 'model': model,
    if (modelName != null) 'modelName': modelName,
    if (contact != null) 'contact': contact,
    if (contactMethod != null) 'contactMethod': contactMethod,
    if (sellerType != null) 'sellerType': sellerType!.code,
  };
}
