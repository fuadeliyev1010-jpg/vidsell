enum ProductCondition {
  newCondition('NEW'),
  likeNew('LIKE_NEW'),
  used('USED'),
  forParts('FOR_PARTS'),
  unknown('UNKNOWN');

  const ProductCondition(this.code);
  final String code;

  static ProductCondition? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => ProductCondition.unknown,
  );
}
