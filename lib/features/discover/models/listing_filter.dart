import 'package:vidsell/models/enums/seller_type.dart';

enum SortOption { recommended, lowestPrice, highestPrice, newest }

class ListingFilter {
  const ListingFilter({
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.cityId,
    this.cityName,
    this.minPrice,
    this.maxPrice,
    this.sort = SortOption.recommended,
    this.sellerType,
  });

  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? cityId;
  final String? cityName;
  final double? minPrice;
  final double? maxPrice;
  final SortOption sort;
  final SellerType? sellerType;

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'cityId': cityId,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
    'sort': sort.name,
    if (sellerType != null) 'sellerType': sellerType!.code,
  };
}
