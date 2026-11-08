// TODO(api): verify against /i18n/enums or openapi.json
final class PaymentMethod {
  const PaymentMethod._(this.code, this._kind);

  static const card = PaymentMethod._('CARD', 'card');
  static const bankTransfer = PaymentMethod._('BANK_TRANSFER', 'bankTransfer');
  static const unknown = PaymentMethod._('UNKNOWN', 'unknown');

  final String code;
  final String _kind;

  bool get isUnknown => _kind == 'unknown';

  static PaymentMethod fromCode(Object? rawCode) {
    final normalized = rawCode?.toString().trim().toUpperCase();
    return switch (normalized) {
      'CARD' => card,
      'BANK_TRANSFER' => bankTransfer,
      'UNKNOWN' || null || '' => unknown,
      _ => PaymentMethod._(rawCode.toString(), 'unknown'),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is PaymentMethod && other._kind == _kind;

  @override
  int get hashCode => _kind.hashCode;
}
