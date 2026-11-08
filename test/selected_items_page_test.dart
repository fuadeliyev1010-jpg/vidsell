import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/discover/bloc/favorites_cubit.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/pages/selected_items_page.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_engagement_repository.dart';
import 'package:vidsell/l10n/app_localizations.dart';

void main() {
  final visibilityUpdateInterval =
      VisibilityDetectorController.instance.updateInterval;

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  tearDown(() {
    VisibilityDetectorController.instance.updateInterval =
        visibilityUpdateInterval;
  });

  testWidgets('an empty favorites response preserves a recent in-memory like', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _EmptyFetchEngagementRepository(
      sessionStore: InMemorySessionStore(),
    );
    final favorites = FavoritesCubit(repository);
    final following = FollowingCubit(repository);
    addTearDown(favorites.close);
    addTearDown(following.close);
    await favorites.toggle(
      listingId: 'recent-listing',
      enabled: true,
      item: const EngagementItem(
        id: 'recent-listing',
        title: 'Recently liked video',
        imageUrl: null,
        subtitle: '100 AZN',
        videoUrl: 'https://cdn.example.test/recent.mp4',
      ),
    );

    await tester.pumpWidget(_savedPage(repository, favorites, following));
    await tester.pumpAndSettle();

    expect(find.text('Recently liked video'), findsOneWidget);
    expect(repository.favoriteFetchCount, 1);
  });

  testWidgets(
    'saved listings and followed stores update from engagement state',
    (tester) async {
      tester.view.physicalSize = const Size(375, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = MockEngagementRepository(
        sessionStore: InMemorySessionStore(),
      );
      final favorites = FavoritesCubit(repository);
      final following = FollowingCubit(repository);
      addTearDown(favorites.close);
      addTearDown(following.close);
      await repository.setFavorite(
        'persisted-listing',
        true,
        item: const EngagementItem(
          id: 'persisted-listing',
          title: 'Persisted listing',
          imageUrl: null,
          subtitle: '50 AZN',
        ),
      );
      await repository.setFollowing(
        'persisted-store',
        true,
        item: const EngagementItem(
          id: 'persisted-store',
          title: 'Persisted store',
          imageUrl: null,
          subtitle: '@persisted',
        ),
      );

      await tester.pumpWidget(_savedPage(repository, favorites, following));
      await tester.pumpAndSettle();
      expect(find.text('Persisted listing'), findsOneWidget);

      await favorites.toggle(
        listingId: 'video-listing',
        enabled: true,
        item: const EngagementItem(
          id: 'video-listing',
          title: 'Saved video listing',
          imageUrl: null,
          subtitle: '100 AZN',
          videoUrl: 'https://cdn.example.test/video.mp4',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Saved video listing'), findsOneWidget);

      await tester.tap(find.text('Mağazalar'));
      await tester.pumpAndSettle();
      expect(find.text('Persisted store'), findsOneWidget);
      await following.toggle(
        storeId: 'store-1',
        enabled: true,
        item: const EngagementItem(
          id: 'store-1',
          title: 'Followed store',
          imageUrl: null,
          subtitle: '@store',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Followed store'), findsOneWidget);
    },
  );
}

Widget _savedPage(
  EngagementRepository repository,
  FavoritesCubit favorites,
  FollowingCubit following,
) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, child) => MultiRepositoryProvider(
      providers: [
        RepositoryProvider<EngagementRepository>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FavoritesCubit>.value(value: favorites),
          BlocProvider<FollowingCubit>.value(value: following),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SelectedItemsPage(),
        ),
      ),
    ),
  );
}

class _EmptyFetchEngagementRepository extends MockEngagementRepository {
  _EmptyFetchEngagementRepository({required super.sessionStore});

  int favoriteFetchCount = 0;

  @override
  Future<List<EngagementItem>> fetchFavorites() async {
    favoriteFetchCount++;
    return const [];
  }
}
