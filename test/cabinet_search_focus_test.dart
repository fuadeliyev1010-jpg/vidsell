import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/cabinet/pages/cabinet_page.dart';
import 'package:vidsell/features/cabinet/repositories/mock_profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/features/cabinet/widgets/inactive_listing_card.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_business_repository.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

void main() {
  testWidgets('cabinet search filters listings and resets on tab change', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, child) => RepositoryProvider<BusinessRepository>.value(
          value: MockBusinessRepository.instance,
          child: RepositoryProvider<UserListingRepository>.value(
            value: _CabinetTestListingRepository(),
            child: RepositoryProvider<StatusCountRepository>.value(
              value: MockStatusCountRepository(),
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: CabinetPage(profileRepository: MockProfileRepository()),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Tab).at(2));
    await tester.tap(find.byType(Tab).at(2));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('cabinet-search-button')),
    );
    await tester.tap(find.byKey(const ValueKey('cabinet-search-button')));
    await tester.pumpAndSettle();

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.focusNode, isNotNull);
    expect(FocusManager.instance.primaryFocus, searchField.focusNode);
    await tester.enterText(find.byType(TextField), 'no matching listing');
    await tester.pumpAndSettle();
    expect(find.byType(InactiveListingCard), findsNothing);

    await tester.ensureVisible(find.byType(Tab).at(1));
    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const ValueKey('cabinet-search-button')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('cabinet-search-button'))).dx,
      lessThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('cabinet-category-filter')))
            .dx,
      ),
    );
    expect(FocusManager.instance.primaryFocus, isNot(searchField.focusNode));

    await tester.ensureVisible(find.byType(Tab).at(2));
    await tester.tap(find.byType(Tab).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cabinet-search-button')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    await tester.enterText(find.byType(TextField), 'iPhone');
    await tester.pumpAndSettle();
    expect(find.byType(InactiveListingCard), findsOneWidget);
  });
}

class _CabinetTestListingRepository implements UserListingRepository {
  final _listing = Product(
    id: 'cabinet-test-1',
    title: 'iPhone',
    price: 2967,
    currency: 'AZN',
    description: '',
    status: ProductStatus.sold,
    sellerId: 'seller-test',
    categoryId: 'electronics',
    subcategoryId: 'phones',
    cityId: 'istanbul',
    city: 'İstanbul',
    imageUrls: ['https://example.com/iphone.jpg'],
    createdAt: DateTime.utc(2026),
  );

  @override
  Future<List<Product>> fetchMyListings({ProductStatus? status}) async => [
    _listing,
  ];

  @override
  Future<void> updateListingStatus(
    String listingId,
    ProductStatus status,
  ) async {}

  @override
  Future<void> deleteListing(String listingId) async {}
}
