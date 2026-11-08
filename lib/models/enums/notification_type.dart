enum NotificationType {
  message('MESSAGE'),
  system('SYSTEM'),
  unknown('UNKNOWN');

  const NotificationType(this.code);
  final String code;

  static NotificationType fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => NotificationType.unknown,
  );
}
