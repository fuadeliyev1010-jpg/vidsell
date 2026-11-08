import '../enums/promotion_type.dart';

class PromotionAvailability {
  const PromotionAvailability({
    required this.freeDailyQuota,
    required this.prices,
    this.currency = 'TRY',
    this.resetsAt,
    this.plans = const [],
  });

  final int freeDailyQuota;
  final Map<String, double> prices;
  final String currency;
  final DateTime? resetsAt;
  final List<PromotionPlanAvailability> plans;

  factory PromotionAvailability.fromJson(Map<String, dynamic> json) {
    final rawPlans = json['plans'];
    final plans = rawPlans is List
        ? rawPlans
              .whereType<Map>()
              .map(
                (plan) => PromotionPlanAvailability.fromJson(
                  Map<String, dynamic>.from(plan),
                ),
              )
              .toList(growable: false)
        : const <PromotionPlanAvailability>[];
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
    for (final plan in plans) {
      if (plan.price != null) prices[plan.type.code] = plan.price!;
    }
    final boostPlan = plans
        .where((plan) => plan.type == PromotionType.boost)
        .firstOrNull;
    final rawQuota =
        json['freeDailyQuota'] ?? json['freeQuota'] ?? boostPlan?.freeRemaining;
    return PromotionAvailability(
      freeDailyQuota: rawQuota is num ? rawQuota.toInt() : 0,
      prices: prices,
      currency: json['currency'] as String? ?? 'TRY',
      resetsAt: DateTime.tryParse('${json['resetsAt'] ?? ''}'),
      plans: plans,
    );
  }

  Map<String, dynamic> toJson() => {
    'currency': currency,
    if (resetsAt != null) 'resetsAt': resetsAt!.toIso8601String(),
    'plans': plans.map((plan) => plan.toJson()).toList(),
  };

  double? priceFor(PromotionType type) => prices[type.code];

  PromotionPlanAvailability? planFor(PromotionType type) =>
      plans.where((plan) => plan.type == type).firstOrNull;
}

class PromotionPlanAvailability {
  const PromotionPlanAvailability({
    required this.type,
    required this.typeLabel,
    required this.freeRemaining,
    required this.freeTotal,
    required this.currency,
    this.price,
    this.periodEnd,
  });

  final PromotionType type;
  final String typeLabel;
  final int freeRemaining;
  final int freeTotal;
  final double? price;
  final String currency;
  final DateTime? periodEnd;

  factory PromotionPlanAvailability.fromJson(Map<String, dynamic> json) =>
      PromotionPlanAvailability(
        type:
            PromotionType.fromCode(json['type'] as String?) ??
            PromotionType.unknown,
        typeLabel: json['typeLabel'] as String? ?? '',
        freeRemaining: (json['freeRemaining'] as num?)?.toInt() ?? 0,
        freeTotal: (json['freeTotal'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble(),
        currency: json['currency'] as String? ?? 'TRY',
        periodEnd: DateTime.tryParse('${json['periodEnd'] ?? ''}'),
      );

  Map<String, dynamic> toJson() => {
    'type': type.code,
    'typeLabel': typeLabel,
    'freeRemaining': freeRemaining,
    'freeTotal': freeTotal,
    if (price != null) 'price': price,
    'currency': currency,
    if (periodEnd != null) 'periodEnd': periodEnd!.toIso8601String(),
  };
}
