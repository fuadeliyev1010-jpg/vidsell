String formatPhoneNumber(String phone) {
  // 1. Strip everything except digits
  final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

  // 2. Check for Azerbaijani prefix '994' followed by 9 digits (12 digits total)
  final regExp = RegExp(r'^(994)(\d{2})(\d{3})(\d{2})(\d{2})$');

  if (regExp.hasMatch(digitsOnly)) {
    return digitsOnly.replaceFirstMapped(
      regExp,
      (m) => '+${m[1]} ${m[2]} ${m[3]} ${m[4]} ${m[5]}',
    );
  }

  // Fallback if format doesn't match
  return phone;
}
