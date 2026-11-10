import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/cabinet/repositories/api_user_listing_repository.dart';
import 'package:vidsell/models/enums/product_status.dart';

void main() {
  test('cabinet listing operations use documented paths and methods', () async {
    final adapter = _UserListingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
    dio.httpClientAdapter = adapter;
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

    final repository = ApiUserListingRepository(client);
    await repository.fetchMyListings(status: ProductStatus.inactive);
    await repository.fetchMyListings(status: ProductStatus.sold);
    await repository.updateListingStatus(
      '00000000-0000-4000-8000-000000000001',
      ProductStatus.active,
    );
    await repository.updateListingStatus(
      '00000000-0000-4000-8000-000000000001',
      ProductStatus.sold,
    );
    await repository.deleteListing('00000000-0000-4000-8000-000000000001');

    expect(adapter.requests.map((request) => (request.method, request.path)), [
      ('GET', '/products/me'),
      ('GET', '/products/me'),
      ('POST', '/products/00000000-0000-4000-8000-000000000001/activate'),
      ('POST', '/products/00000000-0000-4000-8000-000000000001/deactivate'),
      ('DELETE', '/products/00000000-0000-4000-8000-000000000001'),
    ]);
    expect(adapter.requests[0].queryParameters, {'status': 'INACTIVE'});
    expect(adapter.requests[1].queryParameters, {'status': 'SOLD'});
    expect(
      adapter.requests.skip(2).every((request) => request.data == null),
      isTrue,
    );
  });
}

class _UserListingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = options.method == 'GET'
        ? {
            'items': [],
            'page': 0,
            'size': 20,
            'totalElements': 0,
            'totalPages': 0,
            'last': true,
          }
        : {'message': 'ok'};
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
