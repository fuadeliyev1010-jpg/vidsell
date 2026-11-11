import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/state/app_locale_cubit.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';

void main() {
  testWidgets('localized UI updates when the app locale changes', (
    tester,
  ) async {
    final localeCubit = AppLocaleCubit();

    await tester.pumpWidget(
      BlocProvider.value(
        value: localeCubit,
        child: BlocBuilder<AppLocaleCubit, Locale>(
          builder: (context, locale) => MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    Text(context.l10n.settingsTitle),
                    Text(context.l10n.discoverTab),
                    Text(context.l10n.goToStore),
                    Text(context.l10n.mockIphoneListingTitle),
                    Text(context.l10n.localizedAuthError('INVALID_OTP')),
                    Text(context.l10n.paymentMethodCard),
                    Text(context.l10n.paymentMethodBankTransfer),
                    Text(context.l10n.amountRangeError('TRY')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Keşfet'), findsOneWidget);
    expect(find.text('Mağazaya geç'), findsOneWidget);
    expect(
      find.text('Apple iPhone 17 Pro 256GB Cosmic Orange'),
      findsOneWidget,
    );
    expect(find.text('Doğrulama kodu geçersiz.'), findsOneWidget);
    expect(find.text('Kart'), findsOneWidget);
    expect(find.text('Banka havalesi'), findsOneWidget);
    expect(find.text('1-100000 TRY arasında bir tutar girin'), findsOneWidget);

    localeCubit.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Go to store'), findsOneWidget);
    expect(
      find.text('Apple iPhone 17 Pro 256GB Cosmic Orange'),
      findsOneWidget,
    );
    expect(find.text('The verification code is invalid.'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Bank transfer'), findsOneWidget);
    expect(
      find.text('Enter an amount between 1 and 100000 TRY'),
      findsOneWidget,
    );

    localeCubit.setLocale(const Locale('tr'));
    await tester.pumpAndSettle();
    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Keşfet'), findsOneWidget);
    expect(find.text('Mağazaya geç'), findsOneWidget);
    expect(find.text('Doğrulama kodu geçersiz.'), findsOneWidget);

    await localeCubit.close();
  });
}
