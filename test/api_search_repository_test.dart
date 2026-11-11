import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/discover/repositories/api_search_repository.dart';

void main() {
  test('autocomplete parses the documented suggestions envelope', () async {
    final adapter = _SearchResponseAdapter();
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

    final suggestions = await ApiSearchRepository(client).suggestions('camera');

    expect(suggestions.single.title, 'Camera');
    expect(suggestions.single.subtitle, 'Canon, Baku');
    expect(adapter.request!.path, '/search/autocomplete');
    expect(adapter.request!.queryParameters, {'q': 'camera'});
  });
}

class _SearchResponseAdapter implements HttpClientAdapter {
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
        'suggestions': [
          {
            'productId': 'product-1',
            'title': 'Camera',
            'brand': 'Canon',
            'city': 'Baku',
          },
        ],
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
