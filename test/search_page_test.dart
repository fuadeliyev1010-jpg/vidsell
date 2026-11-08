import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/models/search_suggestion.dart';
import 'package:vidsell/features/discover/pages/search_page.dart';
import 'package:vidsell/features/discover/repositories/mock_engagement_repository.dart';
import 'package:vidsell/features/discover/repositories/search_repository.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/l10n/app_localizations.dart';

void main() {
  final engagementRepository = MockEngagementRepository.instance;

  setUp(() async {
    await engagementRepository.clearSavedSearches();
  });

  testWidgets('empty suggestions do not show hardcoded fallback items', (
    tester,
  ) async {
    final repository = _FakeSearchRepository(
      suggestionsRequest: (_) async => const [],
    );
    await _pumpSearchPage(tester, repository, engagementRepository);

    await tester.enterText(find.byType(TextField), 'unmatched query');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Öneri bulunamadı.'), findsOneWidget);
    expect(find.text('iphone'), findsNothing);
  });

  testWidgets('suggestion errors show retry and load suggestions on retry', (
    tester,
  ) async {
    var shouldFail = true;
    final repository = _FakeSearchRepository(
      suggestionsRequest: (_) async {
        if (shouldFail) throw StateError('offline');
        return const [SearchSuggestion(title: 'camera', subtitle: 'Photo')];
      },
    );
    await _pumpSearchPage(tester, repository, engagementRepository);

    await tester.enterText(find.byType(TextField), 'cam');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Öneriler yüklenemedi.'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(find.text('camera'), findsOneWidget);
  });

  testWidgets('late suggestions from an older query are ignored', (
    tester,
  ) async {
    final requests = <String, Completer<List<SearchSuggestion>>>{};
    final repository = _FakeSearchRepository(
      suggestionsRequest: (query) =>
          (requests[query] ??= Completer<List<SearchSuggestion>>()).future,
    );
    await _pumpSearchPage(tester, repository, engagementRepository);

    await tester.enterText(find.byType(TextField), 'old');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.enterText(find.byType(TextField), 'new');
    await tester.pump(const Duration(milliseconds: 350));

    requests['old']!.complete(const [
      SearchSuggestion(title: 'old result', subtitle: ''),
    ]);
    await tester.pump();
    requests['new']!.complete(const [
      SearchSuggestion(title: 'new result', subtitle: ''),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('new result'), findsOneWidget);
    expect(find.text('old result'), findsNothing);
  });
}

Future<void> _pumpSearchPage(
  WidgetTester tester,
  SearchRepository repository,
  MockEngagementRepository engagementRepository,
) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SearchPage(
          repository: repository,
          engagementRepository: engagementRepository,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({required this.suggestionsRequest});

  final Future<List<SearchSuggestion>> Function(String query)
  suggestionsRequest;

  @override
  Future<List<Product>> search(String query) async => const [];

  @override
  Future<List<SearchSuggestion>> suggestions(String query) =>
      suggestionsRequest(query);
}
