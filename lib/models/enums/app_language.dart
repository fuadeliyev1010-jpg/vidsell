enum AppLanguage {
  tr('TR'),
  en('EN'),
  unknown('UNKNOWN');

  const AppLanguage(this.code);
  final String code;

  static AppLanguage? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => AppLanguage.unknown,
  );
}
