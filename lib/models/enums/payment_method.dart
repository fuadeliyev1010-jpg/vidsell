final class PaymentMethod {
  const PaymentMethod._(this.code);

  static const unknown = PaymentMethod._('UNKNOWN');

  final String code;

  bool get isUnknown => code == unknown.code;

  static PaymentMethod fromCode(Object? rawCode) {
    final code = rawCode?.toString().trim();
    return code == null || code.isEmpty ? unknown : PaymentMethod._(code);
  }

  // TODO(api): Load supported method codes from /i18n/enums at runtime.
  static List<PaymentMethodOption> optionsFromI18nResponse(
    Map<String, dynamic> response,
  ) {
    final group = response['paymentMethod'];
    final options = <PaymentMethodOption>[];
    if (group is List) {
      for (final item in group) {
        if (item is Map) {
          options.add(_optionFromMap(Map<String, dynamic>.from(item)));
        }
      }
    } else if (group is Map) {
      for (final entry in group.entries) {
        final code = entry.key.toString();
        final value = entry.value;
        if (value is String) {
          options.add(
            PaymentMethodOption(method: fromCode(code), label: value),
          );
        } else if (value is Map) {
          options.add(
            _optionFromMap(
              Map<String, dynamic>.from(value),
              fallbackCode: code,
            ),
          );
        }
      }
    }
    if (options.isEmpty) {
      throw StateError('The paymentMethod enum group is missing or empty.');
    }
    return List.unmodifiable(options);
  }

  static PaymentMethodOption _optionFromMap(
    Map<String, dynamic> json, {
    String? fallbackCode,
  }) {
    final code = json['code']?.toString() ?? fallbackCode;
    final label =
        json['label']?.toString() ??
        json.entries
            .where((entry) => entry.key.toString().endsWith('Label'))
            .map((entry) => entry.value)
            .whereType<String>()
            .firstOrNull;
    if (code == null || code.trim().isEmpty || label == null || label.isEmpty) {
      throw StateError('Invalid payment method enum option.');
    }
    return PaymentMethodOption(method: fromCode(code), label: label);
  }

  @override
  bool operator ==(Object other) =>
      other is PaymentMethod && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

class PaymentMethodOption {
  const PaymentMethodOption({required this.method, required this.label});

  final PaymentMethod method;
  final String label;
}
