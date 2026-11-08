import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/api_listing_repository.dart';
import 'package:vidsell/models/enums/product_status.dart';

void main() {
  test(
    'create sends only ProductRequest fields and tags documented video',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'vidsell-product-create-',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));
      final videoPath =
          '${tempDirectory.path}${Platform.pathSeparator}video.mp4';
      await File(videoPath).writeAsBytes([1, 2, 3]);

      final adapter = _ProductResponseAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        apiClient.dispose();
        dio.close(force: true);
      });

      final product = await ApiListingRepository(apiClient).createListing(
        _draft(
          videoPaths: [videoPath],
          imagePaths: [
            '${tempDirectory.path}${Platform.pathSeparator}cover.jpg',
          ],
        ),
      );

      expect(product.id, 'product-1');
      expect(product.status, ProductStatus.active);
      expect(adapter.productRequest!.data, {
        'title': 'Phone',
        'description': 'Description',
        'price': 250,
        'currency': 'TRY',
        'category': 'ELECTRONICS',
        'subcategory': 'PHONES',
        'brand': 'Brand',
        'modelName': 'Model',
        'city': 'Baku',
        'condition': 'USED',
        'imageUrls': <String>[],
      });
      expect(adapter.requests.map((request) => request.path), [
        '/products',
        '/videos',
        '/videos/video-1',
        '/videos/video-1/products/product-1',
      ]);
      expect(
        adapter.requests.any((request) => request.path == '/media/upload'),
        isFalse,
      );
    },
  );

  test(
    'API product creation permits no local media and image upload is mock-only',
    () async {
      final adapter = _ProductResponseAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        apiClient.dispose();
        dio.close(force: true);
      });
      final repository = ApiListingRepository(apiClient);

      final product = await repository.createListing(_draft());

      expect(product.status, ProductStatus.active);
      expect(
        adapter.productRequest!.data,
        containsPair('imageUrls', <String>[]),
      );
      await expectLater(
        repository.uploadImages(['local.jpg']),
        throwsUnsupportedError,
      );
    },
  );
}

ListingDraft _draft({
  List<String> imagePaths = const [],
  List<String> videoPaths = const [],
}) => ListingDraft(
  categoryId: 'electronics',
  categoryName: 'Electronics',
  subcategoryId: 'PHONES',
  subcategoryName: 'Phones',
  brand: 'Brand',
  model: 'Model',
  price: 250,
  city: 'Baku',
  cityId: 'city-1',
  condition: ListingCondition.used,
  delivery: DeliveryOption.free,
  title: 'Phone',
  description: 'Description',
  sellerName: 'Contact name',
  email: 'contact@example.test',
  phone: '+994000000000',
  contactMethod: 'callsOnly',
  imagePaths: imagePaths,
  videoPaths: videoPaths,
  videoCoverPaths: imagePaths,
);

class _ProductResponseAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  RequestOptions? productRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/products') productRequest = options;
    final body = switch (options.path) {
      '/products' => _productResponse,
      '/videos' => {
        'id': 'video-1',
        'ownerId': 'seller-1',
        'status': 'PROCESSING',
      },
      '/videos/video-1' => {
        'id': 'video-1',
        'ownerId': 'seller-1',
        'status': 'PROCESSED',
        'hlsUrl': 'https://cdn.example.test/video.m3u8',
      },
      '/videos/video-1/products/product-1' => {
        'id': 'video-1',
        'ownerId': 'seller-1',
        'status': 'PROCESSED',
        'productIds': ['product-1'],
      },
      _ => <String, dynamic>{},
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      options.path == '/products' || options.path == '/videos' ? 201 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _productResponse = {
  'id': 'product-1',
  'sellerId': 'seller-1',
  'sellerFullName': 'Seller',
  'sellerAvatarUrl': null,
  'title': 'Phone',
  'description': 'Description',
  'price': 250,
  'currency': 'TRY',
  'category': 'ELECTRONICS',
  'subcategory': 'PHONES',
  'brand': 'Brand',
  'modelName': 'Model',
  'city': 'Baku',
  'condition': 'USED',
  'viewCount': 0,
  'status': 'ACTIVE',
  'promotionType': 'NONE',
  'promotionEndsAt': null,
  'imageUrls': '[]',
  'createdAt': '2026-06-27T12:00:00Z',
  'updatedAt': '2026-06-27T12:00:00Z',
};
