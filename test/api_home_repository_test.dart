import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/home/repositories/api_home_repository.dart';

void main() {
  test(
    'listing feeds filter by category, subcategory, city and seller IDs',
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
        categoryId: 'category-1',
        subcategoryId: 'subcategory-1',
        cityId: 'city-1',
        sellerId: 'seller-1',
      );

      expect(page.listings, isEmpty);
      expect(page.page, 0);
      expect(adapter.request!.queryParameters, {
        'page': 1,
        'size': 50,
        'categoryId': 'category-1',
        'subcategoryId': 'subcategory-1',
        'cityId': 'city-1',
        'sellerId': 'seller-1',
        'tab': 'FOR_YOU',
      });
    },
  );
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
    return ResponseBody.fromString(
      jsonEncode({
        'items': [],
        'page': 0,
        'size': 50,
        'totalElements': 0,
        'totalPages': 0,
        'last': true,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
