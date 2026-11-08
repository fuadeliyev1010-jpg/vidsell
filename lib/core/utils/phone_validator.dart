enum PhoneCountry {
  azerbaijan(
    flag: '🇦🇿',
    name: 'Azərbaycan',
    dialCode: '+994',
    hint: '50 123 45 67',
  ),
  turkey(flag: '🇹🇷', name: 'Türkiyə', dialCode: '+90', hint: '532 123 45 67');

  const PhoneCountry({
    required this.flag,
    required this.name,
    required this.dialCode,
    required this.hint,
  });

  final String flag;
  final String name;
  final String dialCode;
  final String hint;

  RegExp get regex => switch (this) {
    PhoneCountry.azerbaijan => _azerbaijanMobile,
    PhoneCountry.turkey => _turkeyMobile,
  };
}

// Group 1 = national number without any prefix.
final RegExp _azerbaijanMobile = RegExp(
  r'^(?:\+994|994|0)?((?:10|50|51|55|60|70|77|99)\d{7})$',
);
final RegExp _turkeyMobile = RegExp(
  r'^(?:\+90|90|0)?(5(?:0[1-7]|[345]\d)\d{7})$',
);

class PhoneValidator {
  PhoneValidator._();

  static String clean(String value) =>
      value.replaceAll(RegExp(r'[\s\-\(\)\u00A0\u200B]'), '');

  /// National number (no prefix) or null if invalid for [country].
  static String? national(PhoneCountry country, String input) =>
      country.regex.firstMatch(clean(input.trim()))?.group(1);

  static bool isValid(PhoneCountry country, String input) =>
      national(country, input) != null;

  /// E.164-style number, e.g. +994501234567, or null if invalid.
  static String? normalize(PhoneCountry country, String input) {
    final n = national(country, input);
    return n == null ? null : '${country.dialCode}$n';
  }

  /// Tries every country. AZ (9 digits) and TR (10 digits) never overlap.
  static PhoneCountry? detect(String input) {
    for (final country in PhoneCountry.values) {
      if (isValid(country, input)) return country;
    }
    return null;
  }

  static String? normalizeAny(String input) {
    final country = detect(input);
    return country == null ? null : normalize(country, input);
  }
}
