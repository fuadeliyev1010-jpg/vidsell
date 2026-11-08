import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/pager/app_router.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/l10n/app_localizations.dart';

void main() {
  testWidgets('promotion page shows listing details and selectable services', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
    tester.view.physicalSize = const Size(280, 600);
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
                title: 'Test iPhone',
                price: '2890.24 ₼',
                city: 'İstanbul',
                category: 'Elektronik',
                subcategory: 'Telefonlar',
                image: 'missing-image.jpg',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
        routedPageRoute(),
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
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.newListing), findsOneWidget);
    expect(find.text('Test iPhone'), findsOneWidget);
    expect(find.text(l10n.quotaRemaining(2, 3)), findsOneWidget);
    expect(find.text(l10n.activateVip), findsOneWidget);
    expect(
      tester.widget<Text>(find.text(l10n.vip)).style?.color,
      AppColor.activeColor,
    );

    await tester.tap(find.text(l10n.activateVip));
    await tester.pumpAndSettle();
    expect(find.text(l10n.subscriptionVip), findsOneWidget);
    expect(find.text(l10n.threeDays), findsOneWidget);
    expect(find.text(l10n.free), findsOneWidget);
    expect(find.text(l10n.activateFree), findsOneWidget);
    expect(find.text(l10n.subscriptionMethod), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(l10n.premium));
    await tester.tap(find.text(l10n.premium));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text(l10n.vip)).style?.color, Colors.white);
    expect(
      tester.widget<Text>(find.text(l10n.premium)).style?.color,
      AppColor.activeColor,
    );
    await tester.tap(find.text(l10n.activatePremium));
    await tester.pumpAndSettle();
    expect(find.text(l10n.subscriptionPremium), findsOneWidget);
    expect(find.text(l10n.threeDays), findsOneWidget);
    expect(find.text(l10n.activateFree), findsOneWidget);
    expect(find.text(l10n.subscriptionMethod), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(l10n.boostListing).first);
    await tester.tap(find.text(l10n.boostListing).first);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text(l10n.boostListing)).style?.color,
      AppColor.activeColor,
    );
    await tester.tap(find.text(l10n.listingBoostButton));
    await tester.pumpAndSettle();
    expect(find.text(l10n.boostListing), findsOneWidget);
    expect(find.text(l10n.planTimes(1)), findsOneWidget);
    expect(find.text(l10n.activateFree), findsOneWidget);
  });
}
