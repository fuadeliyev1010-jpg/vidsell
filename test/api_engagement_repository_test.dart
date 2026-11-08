import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/discover/repositories/api_engagement_repository.dart';

void main() {
  test(
    'loads resource IDs from signed-in favorites and followed stores',
    () async {
      final adapter = _EngagementResponseAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      final repository = ApiEngagementRepository(client);
      final favorites = await repository.fetchFavorites();
      final followed = await repository.fetchFollowedStores();
      await repository.setFavorite('listing-1', true);
      await repository.setFavorite('listing-1', false);
      await repository.setFollowing('store-1', true);
      await repository.setFollowing('store-1', false);
      await repository.reportListing(
        listingId: 'listing-1',
        reason: 'spam',
        description: 'This is spam.',
      );
      await repository.blockUser('user-1');

      expect(favorites.single.id, 'listing-1');
      expect(favorites.single.title, 'Camera');
      expect(followed.single.id, 'store-1');
      expect(followed.single.title, 'Camera Store');
      expect(adapter.requests.map((request) => request.path), [
        '/me/favorites',
        '/me/follows',
        '/listings/listing-1/favorite',
        '/listings/listing-1/favorite',
        '/stores/store-1/follow',
        '/stores/store-1/follow',
        '/listings/listing-1/reports',
        '/users/user-1/block',
      ]);
      expect(adapter.requests.map((request) => request.method), [
        'GET',
        'GET',
        'POST',
        'DELETE',
        'POST',
        'DELETE',
        'POST',
        'POST',
      ]);
    },
  );
}

class _EngagementResponseAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = switch (options.path) {
      '/me/favorites' => {
        'data': {
          'items': [
            {
              'id': 'favorite-row-1',
              'listing': {
                'id': 'listing-1',
                'title': 'Camera',
                'price': '500 AZN',
                'imageUrl': 'https://cdn.example.test/camera.jpg',
              },
            },
          ],
        },
      },
      '/me/follows' => {
        'items': [
          {
            'id': 'follow-row-1',
            'store': {'id': 'store-1', 'name': 'Camera Store'},
          },
        ],
      },
      _ => <String, dynamic>{},
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
