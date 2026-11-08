import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/app_router.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/new_listing/pages/listing_promotion_page.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

void main() {
  testWidgets('creation ID and server status survive promotion navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.goToListingPromotion(
                product: const Product(
                  id: 'product-42',
                  title: 'Phone',
                  price: 1250,
                  city: 'Baku',
                  status: ProductStatus.underReview,
                ),
              ),
              child: const Text('Open promotion'),
            ),
          ),
        ),
        listingPromotionRoute(),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => RepositoryProvider<AppConfig>.value(
          value: AppConfig.development,
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('tr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open promotion'));
    await tester.pumpAndSettle();

    final page = tester.widget<ListingPromotionPage>(
      find.byType(ListingPromotionPage),
    );
    expect(page.product.id, 'product-42');
    expect(page.product.status, ProductStatus.underReview);
  });
}
