import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/models/enums/seller_type.dart';

enum ListingCondition { newItem, used }

enum DeliveryOption { free, paid, none }

enum ContactMethod { callsAndMessages, callsOnly, messagesOnly }

class ListingDraft {
  const ListingDraft({
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.brand,
    required this.model,
    required this.price,
    required this.city,
    required this.cityId,
    required this.condition,
    this.delivery,
    required this.title,
    required this.description,
    required this.sellerName,
    required this.email,
    required this.phone,
    required this.contactMethod,
    required this.imagePaths,
    required this.videoPaths,
    this.sellerType = SellerType.individual,
    this.currency = fallbackCurrencyCode,
    this.videoCoverPaths = const [],
  });

  final String categoryId;
  final String categoryName;
  final String subcategoryId;
  final String subcategoryName;
  final String brand;
  final String model;
  final double price;
  final String city;
  final String cityId;
  final String currency;
  final ListingCondition condition;
  final DeliveryOption? delivery;
  final String title;
  final String description;
  final String sellerName;
  final String email;
  final String phone;
  final String contactMethod;
  final List<String> imagePaths;
  final List<String> videoPaths;
  final List<String> videoCoverPaths;
  final SellerType sellerType;
}
