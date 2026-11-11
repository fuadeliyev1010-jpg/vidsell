// TODO(api): not exposed by /i18n/enums; confirm with backend.
final class PaymentMethod {
  const PaymentMethod._(this.code);

  static const unknown = PaymentMethod._('UNKNOWN');
  static const card = PaymentMethod._('CARD');
  static const bankTransfer = PaymentMethod._('BANK_TRANSFER');
  static const values = [card, bankTransfer];

  final String code;

  bool get isUnknown => code == unknown.code;

  static PaymentMethod fromCode(Object? rawCode) {
    final code = rawCode?.toString().trim();
    return switch (code?.toUpperCase()) {
      'CARD' => card,
      'BANK_TRANSFER' => bankTransfer,
      null || '' => unknown,
      _ => unknown,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is PaymentMethod && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
