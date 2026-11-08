enum ProductCategory {
  electronics('ELECTRONICS'),
  transport('TRANSPORT'),
  realEstate('REAL_ESTATE'),
  homeAppliances('HOME_APPLIANCES'),
  specialOccasion('SPECIAL_OCCASION'),
  cosmetics('COSMETICS'),
  unknown('UNKNOWN');

  const ProductCategory(this.code);
  final String code;

  static ProductCategory? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => ProductCategory.unknown,
  );
}
