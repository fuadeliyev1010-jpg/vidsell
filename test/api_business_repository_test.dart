import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/features/discover/repositories/api_business_repository.dart';
import 'package:vidsell/models/store/store.dart';

void main() {
  test('store application and profile edits send documented fields', () async {
    final adapter = _StoreResponseAdapter();
    final (client, dio) = _createClient(adapter);
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
    });
    final repository = ApiBusinessRepository(client);
    const draft = StoreDraft(
      phoneNumber: '+994501234567',
      storeName: 'Test Store',
      slogan: 'Mock-only slogan',
      description: 'Store description',
      categoryNames: ['Elektronik', 'Furniture'],
      city: 'Mock-only city',
      address: 'Mock-only address',
      logoPath: '/local/logo.png',
      bannerPath: '/local/banner.png',
      alwaysOpen: false,
      openDays: ['Monday'],
      openingTime: '09:00',
      closingTime: '18:00',
      email: 'mock@example.test',
      mainPhone: '+994501111111',
      additionalPhones: ['+994502222222'],
      shortNumber: '1234',
    );

    final created = await repository.createStoreApplication(draft);
    expect(created.status, 'APPLICATION');
    final application = adapter.requests[0];
    expect(application.method, 'POST');
    expect(application.path, '/storefronts/me/application');
    expect(application.data, {
      'name': 'Test Store',
      'category': 'ELECTRONICS',
      'open24Hours': false,
      'workingHours': [
        {'day': 'Monday', 'opens': '09:00', 'closes': '18:00'},
      ],
    });

    await repository.updateMyStore(draft);
    final update = adapter.requests[1];
    expect(update.method, 'PUT');
    expect(update.path, '/storefronts/me');
    expect((update.data as Map<String, dynamic>).keys.toSet(), {
      'name',
      'category',
      'description',
      'phone',
      'workingHours',
    });
  });

  test('uses documented owner status and statistics endpoints', () async {
    final adapter = _StoreResponseAdapter(emptyMutationResponses: true);
    final (client, dio) = _createClient(adapter);
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
    });
    final repository = ApiBusinessRepository(client);

    expect((await repository.deactivateMyStore()).status, 'INACTIVE');
    expect(adapter.requests[0].path, '/storefronts/me/deactivate');
    expect(adapter.requests[1].path, '/storefronts/me');
    expect((await repository.reactivateMyStore()).status, 'ACTIVE');
    expect(adapter.requests[2].path, '/storefronts/me/reactivate');
    expect(adapter.requests[3].path, '/storefronts/me');
    final stats = await repository.fetchMyStoreStatistics();
    expect(adapter.requests[4].path, '/storefronts/me/statistics');
    expect(stats.views, 12);
    expect(stats.listings, 3);
    expect(stats.followers, 5);
  });

  test('treats a 404 for the current storefront as no store yet', () async {
    final adapter = _StoreResponseAdapter(notFound: true);
    final (client, dio) = _createClient(adapter);
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
    });

    expect(await ApiBusinessRepository(client).fetchMyStore(), isNull);
    expect(adapter.requests.single.path, '/storefronts/me');
  });

  test(
    'parses the public seller-profile response and uses 1-based product pages',
    () async {
      final adapter = _StoreResponseAdapter();
      final (client, dio) = _createClient(adapter);
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });
      final repository = ApiBusinessRepository(client);

      final store = await repository.fetchPublicStore('seller-2');
      expect(store.displayName, 'Həsən Məmmədov');
      expect(store.logoUrl, 'https://example.test/avatar.png');
      expect(store.isOpen, isNull);
      expect(
        await repository.fetchPublicStoreProducts('seller-2', page: 2),
        isEmpty,
      );
      expect(adapter.requests[1].queryParameters, {'page': 2});
      expect(adapter.requests[0].path, '/storefronts/seller-2');
      expect(adapter.requests[1].path, '/storefronts/seller-2/products');
    },
  );
}

(ApiClient, Dio) _createClient(_StoreResponseAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.httpClientAdapter = adapter;
  final client = ApiClient(
    config: const AppConfig(
      apiBaseUrl: 'https://api.example.test',
      useMockBackend: false,
    ),
    dio: dio,
  );
  return (client, dio);
}

class _StoreResponseAdapter implements HttpClientAdapter {
  _StoreResponseAdapter({
    this.notFound = false,
    this.emptyMutationResponses = false,
  });

  final bool notFound;
  final bool emptyMutationResponses;
  final List<RequestOptions> requests = [];
  String _status = 'APPLICATION';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (notFound) {
      return ResponseBody.fromString(
        '{"message":"No store"}',
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.path.endsWith('/deactivate')) _status = 'INACTIVE';
    if (options.path.endsWith('/reactivate')) _status = 'ACTIVE';
    if (emptyMutationResponses &&
        options.method == 'POST' &&
        (options.path.endsWith('/deactivate') ||
            options.path.endsWith('/reactivate'))) {
      return ResponseBody.fromString(
        '',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final body = options.path.endsWith('/statistics')
        ? {'views': 12, 'listings': 3, 'followers': 5}
        : options.path.endsWith('/seller-2')
        ? {
            'id': 'seller-2',
            'fullName': 'Həsən Məmmədov',
            'avatarUrl': 'https://example.test/avatar.png',
            'createdAt': '2026-01-15T10:00:00Z',
            'stats': {'products': 48, 'views': 24561, 'followers': 71},
          }
        : options.path.endsWith('/products')
        ? {
            'items': [],
            'page': (options.queryParameters['page'] as int? ?? 1) - 1,
            'size': 20,
            'totalElements': 0,
            'totalPages': 0,
            'last': true,
          }
        : {
            'id': 'store-1',
            'name': 'Test Store',
            'category': 'Electronics',
            'description': 'Store description',
            'phone': '+994501111111',
            'workingHours': '09:00-18:00',
            'status': _status,
            'isOpen': false,
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
