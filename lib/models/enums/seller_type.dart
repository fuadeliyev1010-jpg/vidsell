enum SellerType {
  individual('INDIVIDUAL'),
  store('STORE'),
  unknown('UNKNOWN');

  const SellerType(this.code);
  final String code;

  static SellerType? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => SellerType.unknown,
  );
}
