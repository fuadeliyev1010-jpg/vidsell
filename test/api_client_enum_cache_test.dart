import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';

void main() {
  test(
    'enum catalog requests are shared and refreshed on language change',
    () async {
      final adapter = _EnumCatalogAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'))
        ..httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api/v1',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      final results = await Future.wait([
        client.getEnumCatalog(),
        client.getEnumCatalog(),
        client.getEnumCatalog(),
      ]);

      expect(adapter.requestCount, 1);
      expect(results[0], results[1]);
      expect(results[1], results[2]);

      client.setLanguage('en');
      await client.getEnumCatalog();
      expect(adapter.requestCount, 2);

      await client.getEnumCatalog();
      expect(adapter.requestCount, 2);
    },
  );
}

class _EnumCatalogAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    return ResponseBody.fromString(
      jsonEncode({'categories': []}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
