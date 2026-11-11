import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/models/subcategory_category_map.dart';
import 'package:vidsell/features/discover/widgets/category_chip_rows.dart';
import 'package:vidsell/l10n/app_localizations.dart';

void main() {
  const specialOccasion = [
    Subcategory(id: 'WEDDING', label: 'Düğün', categoryId: 'SPECIAL_OCCASION'),
    Subcategory(id: 'CEREMONY', label: 'Tören', categoryId: 'SPECIAL_OCCASION'),
    Subcategory(
      id: 'NATIONAL_CLOTHING',
      label: 'Milli kıyafet',
      categoryId: 'SPECIAL_OCCASION',
    ),
  ];

  test('SPECIAL_OCCASION chip mapping is exactly its three subcategories', () {
    expect(subcategoryCategoryMap['SPECIAL_OCCASION'], [
      'WEDDING',
      'CEREMONY',
      'NATIONAL_CLOTHING',
    ]);
  });

  testWidgets('SPECIAL_OCCASION shows subcategories and no brand chips', (
    tester,
  ) async {
    final selections = <String?>[];
    await _pumpChipRows(
      tester,
      CategoryChipRows(
        categoryId: 'SPECIAL_OCCASION',
        subcategories: specialOccasion,
        selectedSubcategoryId: null,
        selectedBrand: 'all',
        onSubcategorySelected: selections.add,
        onBrandSelected: (_) {},
      ),
    );

    expect(find.text('Düğün'), findsOneWidget);
    expect(find.text('Tören'), findsOneWidget);
    expect(find.text('Milli kıyafet'), findsOneWidget);
    expect(find.text('Samsung'), findsNothing);
    expect(find.text('Apple iPhone'), findsNothing);
    await tester.tap(find.text('Düğün'));
    await tester.pump();
    expect(selections, ['WEDDING']);
    await _pumpChipRows(
      tester,
      CategoryChipRows(
        categoryId: 'SPECIAL_OCCASION',
        subcategories: specialOccasion,
        selectedSubcategoryId: 'WEDDING',
        selectedBrand: 'all',
        onSubcategorySelected: selections.add,
        onBrandSelected: (_) {},
      ),
    );
    await tester.tap(find.text('Düğün'));
    await tester.pump();
    expect(selections, ['WEDDING', null]);
  });

  testWidgets('brand chips appear only for ELECTRONICS', (tester) async {
    const subcategories = [
      Subcategory(id: 'PHONES', label: 'Telefonlar', categoryId: 'ELECTRONICS'),
    ];
    await _pumpChipRows(
      tester,
      CategoryChipRows(
        categoryId: 'ELECTRONICS',
        subcategories: subcategories,
        selectedSubcategoryId: 'PHONES',
        selectedBrand: 'all',
        onSubcategorySelected: (_) {},
        onBrandSelected: (_) {},
      ),
    );
    expect(find.text('Samsung'), findsOneWidget);

    await _pumpChipRows(
      tester,
      CategoryChipRows(
        categoryId: 'TRANSPORT',
        subcategories: subcategories,
        selectedSubcategoryId: null,
        selectedBrand: 'all',
        onSubcategorySelected: (_) {},
        onBrandSelected: (_) {},
      ),
    );
    expect(find.text('Samsung'), findsNothing);
  });

  testWidgets('empty subcategory list hides chip content', (tester) async {
    await _pumpChipRows(
      tester,
      const CategoryChipRows(
        categoryId: 'ELECTRONICS',
        subcategories: [],
        selectedSubcategoryId: null,
        selectedBrand: 'all',
        onSubcategorySelected: _ignoreSubcategory,
        onBrandSelected: _ignoreBrand,
      ),
    );

    expect(find.text('Samsung'), findsNothing);
    expect(find.text('Telefonlar'), findsNothing);
    expect(shouldShowCategoryChipRow(const []), isFalse);
  });
}

Future<void> _pumpChipRows(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _ignoreSubcategory(String? _) {}

void _ignoreBrand(String _) {}
