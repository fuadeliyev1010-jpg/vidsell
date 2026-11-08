enum ListingStatus {
  draft,
  pendingPayment,
  pendingModeration,
  active,
  inactive,
  rejected,
  expired,
  sold,
  deleted,
  unknown;

  static ListingStatus parse(Object? value) {
    final normalized = value?.toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
    return switch (normalized) {
      'draft' => ListingStatus.draft,
      'pending_payment' => ListingStatus.pendingPayment,
      'pending' ||
      'pending_review' ||
      'pending_moderation' => ListingStatus.pendingModeration,
      'active' || 'approved' => ListingStatus.active,
      'inactive' || 'paused' => ListingStatus.inactive,
      'rejected' || 'declined' => ListingStatus.rejected,
      'expired' => ListingStatus.expired,
      'sold' => ListingStatus.sold,
      'deleted' || 'removed' => ListingStatus.deleted,
      _ => ListingStatus.unknown,
    };
  }

  String get apiValue => switch (this) {
    ListingStatus.pendingPayment => 'pending_payment',
    ListingStatus.pendingModeration => 'pending_moderation',
    _ => name,
  };
}

enum ListingMediaType { image, video, unknown }

class ListingMedia {
  const ListingMedia({
    required this.url,
    required this.type,
    this.sortOrder = 0,
    this.thumbnailUrl,
  });

  final String url;
  final ListingMediaType type;
  final int sortOrder;
  final String? thumbnailUrl;

  factory ListingMedia.fromJson(Map<String, dynamic> json) {
    final url =
        json['url'] as String? ??
        json['mediaUrl'] as String? ??
        json['imageUrl'] as String? ??
        json['videoUrl'] as String? ??
        '';
    final rawType = json['type']?.toString().toLowerCase();
    final type = switch (rawType) {
      'image' || 'photo' => ListingMediaType.image,
      'video' => ListingMediaType.video,
      _ => _mediaTypeFromUrl(url),
    };
    return ListingMedia(
      url: url,
      type: type,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      thumbnailUrl:
          json['thumbnailUrl'] as String? ?? json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'type': switch (type) {
      ListingMediaType.image => 'image',
      ListingMediaType.video => 'video',
      ListingMediaType.unknown => 'unknown',
    },
    'sortOrder': sortOrder,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
  };
}

@Deprecated('Use Product or the appropriate API model instead.')
class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.description,
    required this.status,
    required this.sellerId,
    this.businessId,
    required this.categoryId,
    required this.subcategoryId,
    required this.cityId,
    this.cityName = '',
    this.categoryName = '',
    this.subcategoryName = '',
    this.sellerName = '',
    this.sellerHandle = '',
    this.sellerAvatarUrl,
    this.sellerPhone,
    this.brand = '',
    this.model = '',
    this.color = '',
    this.storage = '',
    this.simCard = '',
    this.condition = '',
    this.delivery = '',
    this.latitude,
    this.longitude,
    this.media = const [],
    this.shareUrl = '',
    this.listingNumber = '',
    this.viewCount,
    this.isFavorite = false,
    this.isVip = false,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final double price;
  final String currency;
  final String description;
  final ListingStatus status;
  final String sellerId;
  final String? businessId;
  final String categoryId;
  final String subcategoryId;
  final String cityId;
  final String cityName;
  final String categoryName;
  final String subcategoryName;
  final String sellerName;
  final String sellerHandle;
  final String? sellerAvatarUrl;
  final String? sellerPhone;
  final String brand;
  final String model;
  final String color;
  final String storage;
  final String simCard;
  final String condition;
  final String delivery;
  final double? latitude;
  final double? longitude;
  final List<ListingMedia> media;
  final String shareUrl;
  final String listingNumber;
  final int? viewCount;
  final bool isFavorite;
  final bool isVip;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Listing.fromJson(Map<String, dynamic> json) {
    final contact = json['contact'] is Map<String, dynamic>
        ? json['contact'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rawId = json['id']?.toString().trim() ?? '';
    if (rawId.isEmpty) throw StateError('Listing response has no ID.');

    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '');
    if (price == null) throw StateError('Listing response has no valid price.');

    final currency = _requiredString(json['currency'], 'currency');
    final sellerId = _requiredString(
      json['sellerId'] ?? json['userId'],
      'sellerId',
    );
    final categoryId = _requiredString(json['categoryId'], 'categoryId');
    final subcategoryId = _requiredString(
      json['subcategoryId'],
      'subcategoryId',
    );
    final cityId = _requiredString(json['cityId'], 'cityId');
    final rawStatus = _requiredString(json['status'], 'status');
    final createdAt = _parseDate(json['createdAt'], isRequired: true)!;

    return Listing(
      id: rawId,
      title: json['title'] as String? ?? '',
      price: price,
      currency: currency,
      description: json['description'] as String? ?? '',
      status: ListingStatus.parse(rawStatus),
      sellerId: sellerId,
      businessId: _string(json['businessId'] ?? json['businessAccountId']),
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      cityId: cityId,
      cityName:
          json['cityName'] as String? ??
          json['city'] as String? ??
          json['location'] as String? ??
          '',
      categoryName:
          json['categoryName'] as String? ?? json['category'] as String? ?? '',
      subcategoryName:
          json['subcategoryName'] as String? ??
          json['subCategoryName'] as String? ??
          json['subCategory'] as String? ??
          '',
      sellerName: json['sellerName'] as String? ?? '',
      sellerHandle: json['sellerHandle'] as String? ?? '',
      sellerAvatarUrl:
          json['sellerAvatarUrl'] as String? ??
          json['sellerAvatar'] as String? ??
          json['sellerImageUrl'] as String?,
      sellerPhone:
          json['sellerPhone'] as String? ??
          json['phoneNumber'] as String? ??
          json['phone'] as String? ??
          contact['phone'] as String?,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      color: json['color'] as String? ?? '',
      storage: json['storage'] as String? ?? '',
      simCard: json['simCard'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      delivery: json['delivery'] as String? ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      media: _parseMedia(json),
      shareUrl:
          json['shareUrl'] as String? ?? json['shareLink'] as String? ?? '',
      listingNumber:
          json['listingNumber']?.toString() ??
          json['listing_number']?.toString() ??
          '',
      viewCount: _parseInt(json['viewCount'] ?? json['views']),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isVip: json['isVip'] as bool? ?? json['isPremium'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'currency': currency,
    'description': description,
    'status': status.apiValue,
    'sellerId': sellerId,
    if (businessId != null) 'businessId': businessId,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'cityId': cityId,
    'cityName': cityName,
    'categoryName': categoryName,
    'subcategoryName': subcategoryName,
    'sellerName': sellerName,
    'sellerHandle': sellerHandle,
    if (sellerAvatarUrl != null) 'sellerAvatarUrl': sellerAvatarUrl,
    if (sellerPhone != null) 'sellerPhone': sellerPhone,
    'brand': brand,
    'model': model,
    'color': color,
    'storage': storage,
    'simCard': simCard,
    'condition': condition,
    'delivery': delivery,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'media': media.map((item) => item.toJson()).toList(growable: false),
    'shareUrl': shareUrl,
    'listingNumber': listingNumber,
    if (viewCount != null) 'viewCount': viewCount,
    'isFavorite': isFavorite,
    'isVip': isVip,
    'createdAt': createdAt.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  Listing copyWith({ListingStatus? status, DateTime? updatedAt}) {
    return Listing(
      id: id,
      title: title,
      price: price,
      currency: currency,
      description: description,
      status: status ?? this.status,
      sellerId: sellerId,
      businessId: businessId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      cityId: cityId,
      cityName: cityName,
      categoryName: categoryName,
      subcategoryName: subcategoryName,
      sellerName: sellerName,
      sellerHandle: sellerHandle,
      sellerAvatarUrl: sellerAvatarUrl,
      sellerPhone: sellerPhone,
      brand: brand,
      model: model,
      color: color,
      storage: storage,
      simCard: simCard,
      condition: condition,
      delivery: delivery,
      latitude: latitude,
      longitude: longitude,
      media: media,
      shareUrl: shareUrl,
      listingNumber: listingNumber,
      viewCount: viewCount,
      isFavorite: isFavorite,
      isVip: isVip,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<ListingMedia> _parseMedia(Map<String, dynamic> json) {
    final rawMedia = json['media'] ?? json['mediaItems'];
    final media = <ListingMedia>[];
    if (rawMedia is List) {
      for (var index = 0; index < rawMedia.length; index++) {
        final item = rawMedia[index];
        if (item is Map<String, dynamic>) {
          final parsed = ListingMedia.fromJson(item);
          if (parsed.url.isNotEmpty) {
            media.add(
              ListingMedia(
                url: parsed.url,
                type: parsed.type,
                sortOrder: parsed.sortOrder == 0 ? index : parsed.sortOrder,
                thumbnailUrl: parsed.thumbnailUrl,
              ),
            );
          }
        } else if (item is String && item.isNotEmpty) {
          media.add(
            ListingMedia(
              url: item,
              type: _mediaTypeFromUrl(item),
              sortOrder: index,
            ),
          );
        }
      }
    } else {
      final rawUrls = json['mediaUrls'] ?? json['images'];
      if (rawUrls is List) {
        for (var index = 0; index < rawUrls.length; index++) {
          final item = rawUrls[index];
          if (item is String && item.isNotEmpty) {
            media.add(
              ListingMedia(
                url: item,
                type: _mediaTypeFromUrl(item),
                sortOrder: index,
              ),
            );
          }
        }
      }
    }

    final imageUrl =
        json['imageUrl'] as String? ??
        json['imagePath'] as String? ??
        json['thumbnailUrl'] as String?;
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !media.any((item) => item.url == imageUrl)) {
      media.insert(
        0,
        ListingMedia(url: imageUrl, type: ListingMediaType.image, sortOrder: 0),
      );
    }

    final videoUrl =
        json['videoUrl'] as String? ?? json['video_url'] as String?;
    if (videoUrl != null &&
        videoUrl.isNotEmpty &&
        !media.any((item) => item.url == videoUrl)) {
      media.add(ListingMedia(url: videoUrl, type: ListingMediaType.video));
    }

    media.sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    return List.unmodifiable(media);
  }

  static String? _string(Object? value) => value?.toString();

  static int? _parseInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _parseDate(Object? value, {bool isRequired = false}) {
    if (value == null || value.toString().isEmpty) {
      if (isRequired) throw StateError('Listing response has no createdAt.');
      return null;
    }
    final date = DateTime.tryParse(value.toString());
    if (date == null) throw StateError('Invalid listing timestamp.');
    return date;
  }

  static String _requiredString(Object? value, String field) {
    final result = value?.toString().trim() ?? '';
    if (result.isEmpty) throw StateError('Listing response has no $field.');
    return result;
  }
}

ListingMediaType _mediaTypeFromUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  if (RegExp(r'\.(mp4|mov|m4v|webm)$').hasMatch(path)) {
    return ListingMediaType.video;
  }
  if (RegExp(r'\.(jpg|jpeg|png|gif|webp|heic)$').hasMatch(path)) {
    return ListingMediaType.image;
  }
  return ListingMediaType.unknown;
}
