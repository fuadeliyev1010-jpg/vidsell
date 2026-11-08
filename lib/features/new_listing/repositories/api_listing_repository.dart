import 'package:vidsell/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:vidsell/features/new_listing/models/created_listing.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/listing_repository.dart';
import 'package:vidsell/models/enums/delivery_type.dart';
import 'package:vidsell/models/enums/product_category.dart';
import 'package:vidsell/models/enums/product_condition.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/product/product_request.dart';
import 'package:vidsell/features/new_listing/repositories/api_video_repository.dart';

class ApiListingRepository implements ListingRepository {
  ApiListingRepository(this._client);

  final ApiClient _client;

  ApiVideoRepository get _videos => ApiVideoRepository(_client);

  @override
  Future<CreatedListing> createListing(ListingDraft draft) async {
    if (draft.imagePaths.isEmpty && draft.videoPaths.isEmpty) {
      throw StateError('missing_media');
    }

    final uploadedImages = await _uploadFiles(draft.imagePaths, 'image');
    final uploadedVideos = await _uploadFiles(draft.videoPaths, 'video');
    final videoMedia = <Map<String, dynamic>>[];
    for (var index = 0; index < uploadedVideos.length; index++) {
      final thumbnailPath = index < draft.videoCoverPaths.length
          ? draft.videoCoverPaths[index]
          : '';
      String? thumbnailUrl;
      if (thumbnailPath.isNotEmpty) {
        final imageIndex = draft.imagePaths.indexOf(thumbnailPath);
        thumbnailUrl = imageIndex >= 0
            ? uploadedImages[imageIndex]
            : await _uploadSingleFile(thumbnailPath, 'image');
      }
      videoMedia.add({
        'url': uploadedVideos[index],
        'type': 'video',
        'sortOrder': uploadedImages.length + index,
        'thumbnailUrl': ?thumbnailUrl,
      });
    }
    final media = <Map<String, dynamic>>[
      for (var index = 0; index < uploadedImages.length; index++)
        {'url': uploadedImages[index], 'type': 'image', 'sortOrder': index},
      ...videoMedia,
    ];
    final request = ProductRequest(
      title: draft.title,
      price: draft.price,
      currency: draft.currency,
      description: draft.description,
      categoryId: draft.categoryId,
      subcategoryId: draft.subcategoryId,
      cityId: draft.cityId,
      city: draft.city,
      category: _category(draft.categoryId),
      condition: _condition(draft.condition),
      deliveryType: _delivery(draft.delivery),
      brand: draft.brand,
      model: draft.model,
      imageUrls: media.map((item) => item['url'] as String).toList(),
      contact: {
        'name': draft.sellerName,
        'email': draft.email,
        'phone': draft.phone,
      },
      contactMethod: draft.contactMethod,
      sellerType: draft.sellerType,
    );
    final data = await _client.post(
      '/products',
      data: {
        ...request.toJson(),
        'categoryId': draft.categoryId,
        'subcategoryId': draft.subcategoryId,
        'categoryName': draft.categoryName,
        'subcategoryName': draft.subcategoryName,
        'brand': draft.brand,
        'model': draft.model,
        'price': draft.price,
        'currency': draft.currency,
        'cityId': draft.cityId,
        'cityName': draft.city,
        'condition': draft.condition.name,
        'delivery': draft.delivery.name,
        'sellerType': draft.sellerType.code,
        'title': draft.title,
        'description': draft.description,
        'contact': {
          'name': draft.sellerName,
          'email': draft.email,
          'phone': draft.phone,
        },
        'contactMethod': draft.contactMethod,
        'media': media,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid listing response.');
    }
    final product = Product.fromJson(data);
    final id = product.id.trim();
    if (id.isEmpty) throw StateError('Listing response has no ID.');
    final rawStatus = data['status']?.toString().trim() ?? '';
    if (rawStatus.isEmpty) {
      throw StateError('Listing response has no status.');
    }

    return CreatedListing.fromProduct(product);
  }

  ProductCategory? _category(String value) => switch (value) {
    'electronics' => ProductCategory.electronics,
    'vehicles' || 'transport' => ProductCategory.transport,
    'real-estate' => ProductCategory.realEstate,
    'home-appliances' => ProductCategory.homeAppliances,
    'special-occasion-clothing' => ProductCategory.specialOccasion,
    'cosmetics' => ProductCategory.cosmetics,
    _ => null,
  };

  ProductCondition? _condition(ListingCondition condition) =>
      switch (condition) {
        ListingCondition.newItem => ProductCondition.newCondition,
        ListingCondition.used => ProductCondition.used,
      };

  DeliveryType? _delivery(DeliveryOption delivery) => switch (delivery) {
    DeliveryOption.free || DeliveryOption.paid => DeliveryType.shipping,
    DeliveryOption.none => DeliveryType.pickup,
  };

  Future<List<String>> _uploadFiles(List<String> paths, String type) async {
    final urls = <String>[];
    for (final filePath in paths) {
      urls.add(await _uploadSingleFile(filePath, type));
    }
    return urls;
  }

  Future<String> _uploadSingleFile(String filePath, String type) async {
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }
    if (type == 'video') {
      final video = await _videos.upload(filePath);
      if (video.id.isNotEmpty) {
        final processed = await _videos.waitUntilProcessed(video.id);
        return processed.hlsUrl ?? processed.thumbnailUrl ?? '';
      }
      if (video.hlsUrl?.isNotEmpty == true) return video.hlsUrl!;
    }
    final response = await _client.postMultipart(
      '/media/upload',
      data: FormData.fromMap({
        'type': type,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: path.basename(filePath),
        ),
      }),
    );
    if (response is! Map<String, dynamic> ||
        response['url'] is! String ||
        (response['url'] as String).isEmpty) {
      throw StateError('Invalid media upload response.');
    }
    return response['url'] as String;
  }
}
