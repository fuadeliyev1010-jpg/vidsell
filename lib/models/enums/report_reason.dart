enum ReportReason {
  fraud('FRAUD'),
  prohibitedItem('PROHIBITED_ITEM'),
  spam('SPAM'),
  wrongCategory('WRONG_CATEGORY'),
  misleading('MISLEADING'),
  duplicate('DUPLICATE'),
  other('OTHER'),
  unknown('UNKNOWN');

  const ReportReason(this.code);
  final String code;

  static ReportReason? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => ReportReason.unknown,
  );
}
