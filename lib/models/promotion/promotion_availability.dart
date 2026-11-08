import '../enums/promotion_type.dart';

class PromotionAvailability {
  const PromotionAvailability({
    required this.freeDailyQuota,
    required this.prices,
  });

  final int freeDailyQuota;
  final Map<String, double> prices;

  factory PromotionAvailability.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['prices'] ?? json['promotionPrices'];
    final prices = <String, double>{};
    if (rawPrices is Map) {
      for (final entry in rawPrices.entries) {
        final value = entry.value;
        if (value is num) {
          prices[entry.key.toString().toUpperCase()] = value.toDouble();
        }
      }
    }
    final rawQuota = json['freeDailyQuota'] ?? json['freeQuota'];
    return PromotionAvailability(
      freeDailyQuota: rawQuota is num ? rawQuota.toInt() : 0,
      prices: prices,
    );
  }

  Map<String, dynamic> toJson() => {
    'freeDailyQuota': freeDailyQuota,
    'prices': prices,
  };

  double? priceFor(PromotionType type) => prices[type.code];
}
