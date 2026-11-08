import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/discover/bloc/favorites_cubit.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/repositories/mock_engagement_repository.dart';

void main() {
  test(
    'an empty server response removes a previously confirmed favorite',
    () async {
      final repository = _EmptyFavoritesRepository();
      final favorites = FavoritesCubit(repository);
      addTearDown(favorites.close);

      await favorites.toggle(
        listingId: 'old-favorite',
        enabled: true,
        item: _item('old-favorite'),
      );
      expect(favorites.isFavorite('old-favorite'), isTrue);

      await favorites.load();

      expect(favorites.state, isEmpty);
    },
  );

  test(
    'reset on user change clears state and ignores a pending mutation',
    () async {
      final repository = _EmptyFavoritesRepository(pendMutations: true);
      final favorites = FavoritesCubit(repository);
      addTearDown(favorites.close);

      final mutation = favorites.toggle(
        listingId: 'user-one-favorite',
        enabled: true,
        item: _item('user-one-favorite'),
      );
      expect(favorites.isFavorite('user-one-favorite'), isTrue);

      favorites.reset();
      expect(favorites.state, isEmpty);

      repository.mutation.complete();
      await mutation;
      expect(favorites.state, isEmpty);
    },
  );
}

EngagementItem _item(String id) =>
    EngagementItem(id: id, title: id, imageUrl: null, subtitle: '');

class _EmptyFavoritesRepository extends MockEngagementRepository {
  _EmptyFavoritesRepository({this.pendMutations = false})
    : super(sessionStore: InMemorySessionStore());

  final bool pendMutations;
  final Completer<void> mutation = Completer<void>();

  @override
  Future<List<EngagementItem>> fetchFavorites() async => const [];

  @override
  Future<void> setFavorite(
    String listingId,
    bool enabled, {
    EngagementItem? item,
  }) async {
    if (pendMutations) await mutation.future;
  }
}
