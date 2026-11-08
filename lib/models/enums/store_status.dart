enum StoreStatus {
  application('APPLICATION'),
  active('ACTIVE'),
  inactive('INACTIVE'),
  suspended('SUSPENDED'),
  rejected('REJECTED'),
  unknown('UNKNOWN');

  const StoreStatus(this.code);
  final String code;

  static StoreStatus fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => StoreStatus.unknown,
  );
}
