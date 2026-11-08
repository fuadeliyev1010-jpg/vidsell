enum FeedSection {
  latest('LATEST'),
  featured('FEATURED'),
  unknown('UNKNOWN');

  const FeedSection(this.code);
  final String code;

  static FeedSection fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => FeedSection.unknown,
  );
}
