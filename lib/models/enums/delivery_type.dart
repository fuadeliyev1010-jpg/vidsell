enum DeliveryType {
  shipping('SHIPPING'),
  pickup('PICKUP'),
  both('BOTH'),
  unknown('UNKNOWN');

  const DeliveryType(this.code);
  final String code;

  static DeliveryType? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => DeliveryType.unknown,
  );
}
