enum Role {
  buyer('BUYER'),
  seller('SELLER'),
  unknown('UNKNOWN');

  const Role(this.code);
  final String code;

  static Role? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => Role.unknown,
  );
}
