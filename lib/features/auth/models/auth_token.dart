import 'dart:convert';

String normalizeAuthToken(Object? value) {
  if (value is! String) return '';

  var token = value.trim();
  if (token.length >= 2 && token.startsWith('"') && token.endsWith('"')) {
    try {
      final decoded = jsonDecode(token);
      if (decoded is String) token = decoded.trim();
    } on FormatException {
      // Keep the trimmed value; it will still be safely masked in diagnostics.
    }
  }
  return token;
}
