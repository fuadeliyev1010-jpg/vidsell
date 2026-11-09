import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/auth/bloc/auth_bloc.dart';
import 'package:vidsell/features/auth/models/auth_session.dart';
import 'package:vidsell/features/discover/repositories/mock_engagement_repository.dart';
import 'package:vidsell/models/user/user.dart';

void main() {
  group('AuthState & Model Equatable', () {
    test('identical AuthState instances are value-equal', () {
      const user1 = User(
        id: 'u1',
        identifier: '+994501234567',
        name: 'User',
        email: 'user@example.com',
      );
      const user2 = User(
        id: 'u1',
        identifier: '+994501234567',
        name: 'User',
        email: 'user@example.com',
      );
      expect(user1, equals(user2));

      const session1 = AuthSession(
        accessToken: 'access_123',
        refreshToken: 'refresh_123',
        user: user1,
      );
      const session2 = AuthSession(
        accessToken: 'access_123',
        refreshToken: 'refresh_123',
        user: user2,
      );
      expect(session1, equals(session2));

      const state1 = AuthState(
        status: AuthStatus.authenticated,
        session: session1,
        identifier: '+994501234567',
      );
      const state2 = AuthState(
        status: AuthStatus.authenticated,
        session: session2,
        identifier: '+994501234567',
      );
      expect(state1, equals(state2));
    });

    test('auth operation is independent from global auth status', () {
      const state1 = AuthState(
        status: AuthStatus.unauthenticated,
        operation: AuthOperation.sendingOtp,
      );
      const state2 = AuthState(
        status: AuthStatus.unauthenticated,
        operation: AuthOperation.otpSent,
      );
      expect(state1.status, state2.status);
      expect(state1, isNot(equals(state2)));

      final errorState1 = state1.copyWith(errorMessage: 'Error A');
      final errorState2 = state1.copyWith(errorMessage: 'Error B');
      expect(errorState1, isNot(equals(errorState2)));
    });
  });

  group('MockEngagementRepository saved searches', () {
    late MockEngagementRepository repo;

    setUp(() {
      repo = MockEngagementRepository.instance;
    });

    test('saves, fetches, deletes, and clears saved searches', () async {
      await repo.clearSavedSearches();
      expect(await repo.fetchSavedSearches(), isEmpty);

      final saved1 = await repo.saveSearch('iPhone 15');
      expect(saved1.query, 'iPhone 15');

      final searchesAfterOne = await repo.fetchSavedSearches();
      expect(searchesAfterOne.length, 1);
      expect(searchesAfterOne.first.query, 'iPhone 15');

      final saved2 = await repo.saveSearch('Mercedes');
      expect(saved2.query, 'Mercedes');

      final searchesAfterTwo = await repo.fetchSavedSearches();
      expect(searchesAfterTwo.length, 2);
      expect(searchesAfterTwo.first.query, 'Mercedes');

      await repo.deleteSavedSearch(saved1.id);
      final searchesAfterDelete = await repo.fetchSavedSearches();
      expect(searchesAfterDelete.length, 1);
      expect(searchesAfterDelete.first.query, 'Mercedes');

      await repo.clearSavedSearches();
      expect(await repo.fetchSavedSearches(), isEmpty);
    });
  });
}
