import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/models/subcategory_category_map.dart';

void main() {
  test('parses flat subcategory values and prefers Turkish enum labels', () {
    final result = Subcategory.fromApiResponse(
      ['WEDDING', 'CEREMONY', 'NATIONAL_CLOTHING'],
      _enumResponse,
      categoryId: 'special-occasion-clothing',
    );

    expect(result.map((item) => item.id), [
      'WEDDING',
      'CEREMONY',
      'NATIONAL_CLOTHING',
    ]);
    expect(result.map((item) => item.label), [
      'Düğün',
      'Tören',
      'NATIONAL_CLOTHING',
    ]);
  });

  test('SPECIAL_OCCASION filters to its mapped subcategories', () {
    final result = Subcategory.fromApiResponse(
      _liveSubcategoryValues,
      _enumResponse,
      categoryId: 'special-occasion-clothing',
    );

    expect(result.map((item) => item.id), [
      'WEDDING',
      'CEREMONY',
      'NATIONAL_CLOTHING',
    ]);
  });

  test('all 24 live values belong to exactly one category', () {
    final values = subcategoryCategoryMap.values.expand((items) => items);

    expect(values, hasLength(24));
    expect(values.toSet(), hasLength(24));
    expect(values.toSet(), containsAll(_liveSubcategoryValues));
  });

  test('valid empty backend list produces no subcategories', () {
    final result = Subcategory.fromApiResponse(const [], const {
      'groups': {'productSubcategory': <Map<String, String>>[]},
    }, categoryId: 'special-occasion-clothing');

    expect(result, isEmpty);
  });

  test('unknown backend values are ignored and logged without throwing', () {
    final logs = <String>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = previousDebugPrint);

    final result = Subcategory.fromApiResponse(
      ['NEW_BACKEND_VALUE', 'WEDDING'],
      _enumResponse,
      categoryId: 'special-occasion-clothing',
    );

    expect(result.map((item) => item.id), ['WEDDING']);
    expect(logs.join('\n'), contains('NEW_BACKEND_VALUE'));
  });
}

const _liveSubcategoryValues = [
  'PHONES',
  'COMPUTERS',
  'TABLETS',
  'TV_AUDIO',
  'ACCESSORIES',
  'CARS',
  'MOTORCYCLES',
  'BICYCLES',
  'SPARE_PARTS',
  'APARTMENTS',
  'HOUSES',
  'LANDS',
  'COMMERCIAL',
  'REFRIGERATORS',
  'WASHING_MACHINES',
  'AIR_CONDITIONERS',
  'KITCHEN_APPLIANCES',
  'WEDDING',
  'CEREMONY',
  'NATIONAL_CLOTHING',
  'PERFUME',
  'SKINCARE',
  'MAKEUP',
  'HAIRCARE',
];

const _enumResponse = {
  'groups': {
    'productSubcategory': [
      {'value': 'WEDDING', 'label': 'Wedding', 'labelTr': 'Düğün'},
      {'value': 'CEREMONY', 'label': 'Ceremony', 'labelTr': 'Tören'},
      {'value': 'NATIONAL_CLOTHING', 'label': 'National clothing'},
    ],
  },
};
