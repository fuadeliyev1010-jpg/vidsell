// Vidsell widget smoke test.
//
// Verifies that the root app widget builds and renders the login page
// without throwing any errors.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import 'package:vidsell/main.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (
    WidgetTester tester,
  ) async {
    // Wrap in ScreenUtilInit so .sp / .w / .h extensions work in tests.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, child) => const MyApp(),
      ),
    );

    // App should render at least one Scaffold (the LoginPage).
    expect(find.byType(Scaffold), findsWidgets);
  });
}
