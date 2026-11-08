enum FeedContentType {
  recent('RECENT'),
  premium('PREMIUM'),
  vip('VIP'),
  popular('POPULAR'),
  sponsored('SPONSORED'),
  recentlyViewed('RECENTLY_VIEWED'),
  unknown('UNKNOWN');

  const FeedContentType(this.code);
  final String code;

  static FeedContentType? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => FeedContentType.unknown,
  );
}
