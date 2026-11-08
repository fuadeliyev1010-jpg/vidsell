// TODO(api): verify against /i18n/enums or openapi.json
final class ProductSubcategory {
  const ProductSubcategory._(this.code, this._kind);

  static const phones = ProductSubcategory._('PHONES', 'phones');
  static const computers = ProductSubcategory._('COMPUTERS', 'computers');
  static const tablets = ProductSubcategory._('TABLETS', 'tablets');
  static const tvAudio = ProductSubcategory._('TV_AUDIO', 'tvAudio');
  static const accessories = ProductSubcategory._('ACCESSORIES', 'accessories');
  static const cars = ProductSubcategory._('CARS', 'cars');
  static const unknown = ProductSubcategory._('UNKNOWN', 'unknown');

  final String code;
  final String _kind;

  bool get isUnknown => _kind == 'unknown';

  static ProductSubcategory fromCode(Object? rawCode) {
    final normalized = rawCode?.toString().trim().toUpperCase();
    return switch (normalized) {
      'PHONES' => phones,
      'COMPUTERS' => computers,
      'TABLETS' => tablets,
      'TV_AUDIO' => tvAudio,
      'ACCESSORIES' => accessories,
      'CARS' => cars,
      'UNKNOWN' || null || '' => unknown,
      _ => ProductSubcategory._(rawCode.toString(), 'unknown'),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is ProductSubcategory && other._kind == _kind;

  @override
  int get hashCode => _kind.hashCode;
}
