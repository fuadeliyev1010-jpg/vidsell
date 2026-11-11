import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/discover/repositories/api_catalog_repository.dart';

void main() {
  test('categories and cities use the product catalog endpoints', () async {
    final adapter = _SubcategoryAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
    dio.httpClientAdapter = adapter;
    final client = ApiClient(
      config: const AppConfig(
        apiBaseUrl: 'https://api.example.test/api',
        useMockBackend: false,
      ),
      dio: dio,
    );
    addTearDown(() {
      client.dispose();
      dio.close(force: true);
    });

    final categories = await ApiSubcategoryRepository(client).fetchCategories();
    final cities = await ApiCityRepository(client).fetchCities();

    expect(categories, ['ELECTRONICS', 'TRANSPORT']);
    expect(cities.map((city) => city.name), ['Baku', 'Ganja']);
    expect(adapter.requests.map((request) => request.path), [
      '/products/categories',
      '/products/cities',
    ]);
  });

  test(
    'subcategory repository uses documented codes and localized labels',
    () async {
      final adapter = _SubcategoryAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      final subcategories = await ApiSubcategoryRepository(
        client,
      ).fetchForCategory('electronics');

      expect(subcategories.map((subcategory) => subcategory.id), [
        'PHONES',
        'COMPUTERS',
      ]);
      expect(subcategories.map((subcategory) => subcategory.label), [
        'Phones',
        'Computers',
      ]);
      expect(adapter.requests.map((request) => request.path), [
        '/products/subcategories',
        '/i18n/enums',
      ]);
      expect(adapter.requests.first.queryParameters, {
        'category': 'ELECTRONICS',
      });
      expect(
        adapter.requests.every(
          (request) => request.headers['X-App-Language'] == 'tr',
        ),
        isTrue,
      );
    },
  );
}

class _SubcategoryAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = switch (options.path) {
      '/products/categories' => ['ELECTRONICS', 'TRANSPORT'],
      '/products/cities' => ['Baku', 'Ganja'],
      '/products/subcategories' => ['PHONES', 'COMPUTERS'],
      '/i18n/enums' => {
        'productSubcategory': {
          'PHONES': {'label': 'Phones'},
          'COMPUTERS': {'label': 'Computers'},
        },
      },
      _ => throw StateError('Unexpected API route: ${options.path}'),
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
