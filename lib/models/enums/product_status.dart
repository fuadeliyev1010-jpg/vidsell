enum ProductStatus {
  active('ACTIVE'),
  sold('SOLD'),
  underReview('UNDER_REVIEW'),
  inactive('INACTIVE'),
  rejected('REJECTED'),
  pendingPayment('PENDING_PAYMENT'),
  deleted('DELETED'),
  unknown('UNKNOWN');

  const ProductStatus(this.code);
  final String code;

  static ProductStatus? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => ProductStatus.unknown,
  );
}
