import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/home/repositories/api_home_repository.dart';

void main() {
  test(
    'filtered Discover products use documented filters and product response shape',
    () async {
      final adapter = _HomeResponseAdapter();
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

      final page = await ApiHomeRepository(client).fetchListings(
        page: 1,
        size: 50,
        categoryId: 'electronics',
        subcategoryId: 'PHONES',
        cityId: 'Baku',
        sellerId: 'seller-1',
      );

      expect(page.items.single.videoId, 'product-1');
      expect(page.items.single.product?.title, 'Camera');
      expect(page.items.single.product?.imageUrls, [
        'https://cdn.example.test/camera.jpg',
      ]);
      expect(page.page, 0);
      expect(adapter.request!.path, '/products');
      expect(adapter.request!.queryParameters, {
        'page': 0,
        'size': 50,
        'category': 'ELECTRONICS',
        'subcategory': 'PHONES',
        'city': 'Baku',
        'sellerId': 'seller-1',
      });
    },
  );

  test('unfiltered Home feed uses the feed endpoint', () async {
    final adapter = _HomeResponseAdapter();
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

    await ApiHomeRepository(client).fetchListings();

    expect(adapter.request!.path, '/feed');
    expect(adapter.request!.queryParameters, {
      'page': 1,
      'size': 5,
      'tab': 'FOR_YOU',
    });
  });
}

class _HomeResponseAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final productResponse = options.path == '/products'
        ? {
            'items': [
              {
                'id': 'product-1',
                'title': 'Camera',
                'price': 500,
                'currency': 'AZN',
                'imageUrls': 'https://cdn.example.test/camera.jpg',
                'category': 'ELECTRONICS',
                'createdAt': '2026-10-30T12:00:00Z',
              },
            ],
            'page': 0,
            'size': 50,
            'totalElements': 1,
            'totalPages': 1,
            'last': true,
          }
        : {
            'items': [],
            'page': 0,
            'size': 50,
            'totalElements': 0,
            'totalPages': 0,
            'last': true,
          };
    return ResponseBody.fromString(
      jsonEncode(productResponse),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
