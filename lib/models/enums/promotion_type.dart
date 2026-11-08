enum PromotionType {
  none('NONE'),
  boost('BOOST'),
  vip('VIP'),
  premium('PREMIUM'),
  unknown('UNKNOWN');

  const PromotionType(this.code);
  final String code;

  static PromotionType? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => PromotionType.unknown,
  );
}
