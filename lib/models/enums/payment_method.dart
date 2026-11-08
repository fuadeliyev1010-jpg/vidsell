import '../common/localized_enum_values.dart';

final class PaymentMethod {
  const PaymentMethod._(this.code);

  static const unknown = PaymentMethod._('UNKNOWN');
  static const card = PaymentMethod._('CARD');
  static const bankTransfer = PaymentMethod._('BANK_TRANSFER');

  final String code;

  bool get isUnknown => code == unknown.code;

  static PaymentMethod fromCode(Object? rawCode) {
    final code = rawCode?.toString().trim();
    return switch (code?.toUpperCase()) {
      'CARD' => card,
      'BANK_TRANSFER' => bankTransfer,
      null || '' => unknown,
      _ => PaymentMethod._(code!),
    };
  }

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
