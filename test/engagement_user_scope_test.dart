import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/discover/bloc/favorites_cubit.dart';
import 'package:vidsell/features/discover/bloc/following_cubit.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/repositories/mock_engagement_repository.dart';
import 'package:vidsell/models/user/user.dart';

void main() {
  test('mock favorites and follows are isolated by signed-in user', () async {
    final sessionStore = InMemorySessionStore();
    final repository = MockEngagementRepository(sessionStore: sessionStore);
    final favorites = FavoritesCubit(repository);
    final following = FollowingCubit(repository);
    addTearDown(favorites.close);
    addTearDown(following.close);

    await sessionStore.write(_session('user-1'));
    await favorites.toggle(
      listingId: 'listing-1',
      enabled: true,
      item: const EngagementItem(
        id: 'listing-1',
        title: 'Video listing',
        imageUrl: 'https://cdn.example.test/video-thumb.jpg',
        subtitle: '100 AZN',
        videoUrl: 'https://cdn.example.test/video.mp4',
      ),
    );
    await following.toggle(storeId: 'store-1', enabled: true);
    favorites.reset();
    following.reset();
    await favorites.load();
    await following.load();
    expect(favorites.isFavorite('listing-1'), isTrue);
    expect(
      (await repository.fetchFavorites()).single.videoUrl,
      'https://cdn.example.test/video.mp4',
    );
    expect(following.isFollowing('store-1'), isTrue);

    await sessionStore.write(_session('user-2'));
    favorites.reset();
    following.reset();
    expect(favorites.state, isEmpty);
    await favorites.load();
    await following.load();
    expect(favorites.isFavorite('listing-1'), isFalse);
    expect(following.isFollowing('store-1'), isFalse);

    await sessionStore.write(_session('user-1'));
    favorites.reset();
    following.reset();
    await favorites.load();
    await following.load();
    expect(favorites.isFavorite('listing-1'), isTrue);
    expect(following.isFollowing('store-1'), isTrue);
  });
}

AuthSession _session(String userId) => AuthSession(
  accessToken: 'access-$userId',
  refreshToken: 'refresh-$userId',
  user: User(
    id: userId,
    identifier: '$userId@example.test',
    name: userId,
    email: '$userId@example.test',
  ),
);
