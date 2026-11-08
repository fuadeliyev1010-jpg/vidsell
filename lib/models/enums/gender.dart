enum Gender {
  male('MALE'),
  female('FEMALE'),
  unknown('UNKNOWN');

  const Gender(this.code);
  final String code;

  static Gender? fromCode(String? code) => values.firstWhere(
    (value) => value.code == code?.trim().toUpperCase(),
    orElse: () => Gender.unknown,
  );
}
