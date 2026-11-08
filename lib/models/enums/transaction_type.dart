enum TransactionType {
  earning('EARNING'),
  deposit('DEPOSIT'),
  topUp('TOP_UP'),
  withdrawal('WITHDRAWAL'),
  adjustment('ADJUSTMENT'),
  unknown('UNKNOWN');

  const TransactionType(this.code);
  final String code;

  static TransactionType? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => TransactionType.unknown,
  );
}
