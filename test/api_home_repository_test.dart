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

  test(
    'special occasion subcategory filter sends category and subcategory',
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

      await ApiHomeRepository(client).fetchListings(
        categoryId: 'special-occasion-clothing',
        subcategoryId: 'WEDDING',
        size: 50,
      );

      expect(adapter.request!.path, '/products');
      expect(adapter.request!.queryParameters, {
        'page': 0,
        'size': 50,
        'category': 'SPECIAL_OCCASION',
        'subcategory': 'WEDDING',
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

  test('maps relative media URLs from a backend feed item', () async {
    final adapter = _HomeResponseAdapter(
      response: {
        'items': [
          {
            'videoId': 'video-1',
            'hlsUrl':
                '/uploads/videos/videos/owner-1/video-1/hls/playlist.m3u8',
            'thumbnailUrl':
                '/uploads/videos/videos/owner-1/video-1/thumbnail.jpg',
            'ownerAvatarUrl': '/uploads/users/owner-1/avatar.jpg',
            'products': [
              {
                'productId': 'product-1',
                'title': 'Camera',
                'price': 500,
                'currency': 'AZN',
                'imageUrl': '/uploads/products/product-1/image.jpg',
              },
            ],
          },
        ],
        'page': 1,
        'size': 5,
        'totalElements': 1,
        'totalPages': 1,
        'last': true,
      },
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1/'));
    dio.httpClientAdapter = adapter;
    final client = ApiClient(
      config: const AppConfig(
        apiBaseUrl: 'http://localhost:8080/api/v1/',
        useMockBackend: false,
      ),
      dio: dio,
    );
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
    });

    final feed = await ApiHomeRepository(client).fetchListings();
    final item = feed.items.single;

    expect(
      item.videoUrl,
      'http://localhost:8080/uploads/videos/videos/owner-1/video-1/hls/playlist.m3u8',
    );
    expect(
      item.thumbnailUrl,
      'http://localhost:8080/uploads/videos/videos/owner-1/video-1/thumbnail.jpg',
    );
    expect(
      item.ownerAvatarUrl,
      'http://localhost:8080/uploads/users/owner-1/avatar.jpg',
    );
    expect(item.product!.imageUrls, [
      'http://localhost:8080/uploads/products/product-1/image.jpg',
    ]);
  });
}

class _HomeResponseAdapter implements HttpClientAdapter {
  _HomeResponseAdapter({this.response});

  final Map<String, dynamic>? response;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final productResponse =
        response ??
        (options.path == '/products'
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
              });
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
