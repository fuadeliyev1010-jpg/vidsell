enum FeedTab {
  forYou('FOR_YOU'),
  nearby('NEARBY'),
  following('FOLLOWING'),
  unknown('UNKNOWN');

  const FeedTab(this.code);
  final String code;

  static FeedTab? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => FeedTab.unknown,
  );
}
