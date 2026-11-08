class LocalizedEnumValues {
  const LocalizedEnumValues._();

  static Map<String, String> fromResponse(
    dynamic response, {
    required String group,
  }) {
    if (response is! Map) {
      throw StateError('Invalid enum localization response.');
    }
    var root = Map<String, dynamic>.from(response);
    if (root['data'] is Map) {
      root = Map<String, dynamic>.from(root['data'] as Map);
    }
    final values = root[group];
    final labels = <String, String>{};

    if (values is Map) {
      for (final entry in values.entries) {
        final code = entry.key.toString();
        final label = _label(entry.value);
        if (label != null) labels[code.toUpperCase()] = label;
      }
    } else if (values is List) {
      for (final value in values) {
        if (value is! Map) continue;
        final item = Map<String, dynamic>.from(value);
        final code = item['code']?.toString();
        final label = _label(item);
        if (code != null && label != null) {
          labels[code.toUpperCase()] = label;
        }
      }
    }

    if (labels.isEmpty) {
      throw StateError('The $group enum group is missing or empty.');
    }
    return Map.unmodifiable(labels);
  }

  static String? _label(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    final label = map['label'];
    if (label is String && label.isNotEmpty) return label;
    for (final entry in map.entries) {
      if (entry.key.endsWith('Label') &&
          entry.value is String &&
          (entry.value as String).isNotEmpty) {
        return entry.value as String;
      }
    }
    return null;
  }
}
