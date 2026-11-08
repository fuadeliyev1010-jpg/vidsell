import '../enums/promotion_type.dart';

class PromoteRequest {
  const PromoteRequest({required this.promotionType, required this.days});

  final PromotionType promotionType;
  final int days;

  Map<String, dynamic> toJson() => {
    'promotionType': promotionType.code,
    'days': days,
  };
}
