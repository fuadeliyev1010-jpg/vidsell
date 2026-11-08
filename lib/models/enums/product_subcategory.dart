final class ProductSubcategory {
  const ProductSubcategory._(this.code, this._kind);

  static const phones = ProductSubcategory._('PHONES', 'phones');
  static const computers = ProductSubcategory._('COMPUTERS', 'computers');
  static const tablets = ProductSubcategory._('TABLETS', 'tablets');
  static const tvAudio = ProductSubcategory._('TV_AUDIO', 'tvAudio');
  static const accessories = ProductSubcategory._('ACCESSORIES', 'accessories');
  static const cars = ProductSubcategory._('CARS', 'cars');
  static const motorcycles = ProductSubcategory._('MOTORCYCLES', 'motorcycles');
  static const bicycles = ProductSubcategory._('BICYCLES', 'bicycles');
  static const spareParts = ProductSubcategory._('SPARE_PARTS', 'spareParts');
  static const apartments = ProductSubcategory._('APARTMENTS', 'apartments');
  static const houses = ProductSubcategory._('HOUSES', 'houses');
  static const lands = ProductSubcategory._('LANDS', 'lands');
  static const commercial = ProductSubcategory._('COMMERCIAL', 'commercial');
  static const refrigerators = ProductSubcategory._(
    'REFRIGERATORS',
    'refrigerators',
  );
  static const washingMachines = ProductSubcategory._(
    'WASHING_MACHINES',
    'washingMachines',
  );
  static const airConditioners = ProductSubcategory._(
    'AIR_CONDITIONERS',
    'airConditioners',
  );
  static const kitchenAppliances = ProductSubcategory._(
    'KITCHEN_APPLIANCES',
    'kitchenAppliances',
  );
  static const wedding = ProductSubcategory._('WEDDING', 'wedding');
  static const ceremony = ProductSubcategory._('CEREMONY', 'ceremony');
  static const nationalClothing = ProductSubcategory._(
    'NATIONAL_CLOTHING',
    'nationalClothing',
  );
  static const perfume = ProductSubcategory._('PERFUME', 'perfume');
  static const skincare = ProductSubcategory._('SKINCARE', 'skincare');
  static const makeup = ProductSubcategory._('MAKEUP', 'makeup');
  static const haircare = ProductSubcategory._('HAIRCARE', 'haircare');
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
      'MOTORCYCLES' => motorcycles,
      'BICYCLES' => bicycles,
      'SPARE_PARTS' => spareParts,
      'APARTMENTS' => apartments,
      'HOUSES' => houses,
      'LANDS' => lands,
      'COMMERCIAL' => commercial,
      'REFRIGERATORS' => refrigerators,
      'WASHING_MACHINES' => washingMachines,
      'AIR_CONDITIONERS' => airConditioners,
      'KITCHEN_APPLIANCES' => kitchenAppliances,
      'WEDDING' => wedding,
      'CEREMONY' => ceremony,
      'NATIONAL_CLOTHING' => nationalClothing,
      'PERFUME' => perfume,
      'SKINCARE' => skincare,
      'MAKEUP' => makeup,
      'HAIRCARE' => haircare,
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
