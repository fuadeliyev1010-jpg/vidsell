import '../common/localized_enum_values.dart';

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
    final labels = LocalizedEnumValues.fromResponse(
      response,
      group: 'paymentMethod',
    );
    return List.unmodifiable([
      for (final entry in labels.entries)
        PaymentMethodOption(method: fromCode(entry.key), label: entry.value),
    ]);
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
