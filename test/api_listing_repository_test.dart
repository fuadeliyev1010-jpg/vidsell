import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/api_listing_repository.dart';

void main() {
  test(
    'create sends relationship IDs, media metadata, and contact separately',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'vidsell-listing-upload-',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));
      final imagePath =
          '${tempDirectory.path}${Platform.pathSeparator}photo.jpg';
      final videoPath =
          '${tempDirectory.path}${Platform.pathSeparator}video.mp4';
      await File(imagePath).writeAsBytes([1, 2, 3]);
      await File(videoPath).writeAsBytes([4, 5, 6]);

      final adapter = _ListingResponseAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        apiClient.dispose();
        dio.close(force: true);
      });

      final created = await ApiListingRepository(apiClient).createListing(
        ListingDraft(
          categoryId: 'category-1',
          categoryName: 'Electronics',
          subcategoryId: 'subcategory-1',
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
          imagePaths: [imagePath],
          videoPaths: [videoPath],
        ),
      );

      final payload = adapter.listingRequest!.data as Map<String, dynamic>;
      expect(created.id, 'created-1');
      expect(created.status, ListingStatus.pendingModeration);
      expect(adapter.mediaUploadCount, 2);
      expect(payload['categoryId'], 'category-1');
      expect(payload['subcategoryId'], 'subcategory-1');
      expect(payload['cityId'], 'city-1');
      expect(payload['cityName'], 'Baku');
      expect(payload['media'], [
        {
          'url': 'https://cdn.example.test/upload-1.jpg',
          'type': 'image',
          'sortOrder': 0,
        },
        {
          'url': 'https://cdn.example.test/upload-2.mp4',
          'type': 'video',
          'sortOrder': 1,
        },
      ]);
      expect(payload['contact'], {
        'name': 'Contact name',
        'email': 'contact@example.test',
        'phone': '+994000000000',
      });
      expect(payload['contactMethod'], 'callsOnly');
      expect(payload.containsKey('sellerId'), isFalse);
      expect(payload.containsKey('sellerName'), isFalse);
      expect(payload.containsKey('sellerEmail'), isFalse);
      expect(payload.containsKey('sellerPhone'), isFalse);
    },
  );

  test('create rejects listings without photos or videos', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    final apiClient = ApiClient(
      config: const AppConfig(
        apiBaseUrl: 'https://api.example.test',
        useMockBackend: false,
      ),
      dio: dio,
    );
    addTearDown(() {
      apiClient.dispose();
      dio.close(force: true);
    });

    expect(
      () => ApiListingRepository(apiClient).createListing(_draftWithoutMedia),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'missing_media',
        ),
      ),
    );
  });
}

const _draftWithoutMedia = ListingDraft(
  categoryId: 'category-1',
  categoryName: 'Electronics',
  subcategoryId: 'subcategory-1',
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
  imagePaths: [],
  videoPaths: [],
);

class _ListingResponseAdapter implements HttpClientAdapter {
  RequestOptions? listingRequest;
  int mediaUploadCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/media/upload')) {
      mediaUploadCount++;
      final url = mediaUploadCount == 1
          ? 'https://cdn.example.test/upload-1.jpg'
          : 'https://cdn.example.test/upload-2.mp4';
      return ResponseBody.fromString(
        jsonEncode({'url': url}),
        201,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    listingRequest = options;
    return ResponseBody.fromString(
      jsonEncode({'id': 'created-1', 'status': 'pending_moderation'}),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
