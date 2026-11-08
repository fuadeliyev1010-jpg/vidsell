import '../../core/utils/video_url_resolver.dart';
import '../enums/feed_content_type.dart';
import '../product/product.dart';

class FeedItem {
  const FeedItem({
    required this.videoId,
    this.thumbnailUrl,
    this.hlsUrl,
    this.rawUrl,
    this.durationSeconds,
    this.contentType,
    this.products = const [],
    this.createdAt,
    this.ownerId,
    this.ownerName,
    this.ownerAvatarUrl,
  });

  final String videoId;
  final String? thumbnailUrl;
  final String? hlsUrl;
  final String? rawUrl;
  final int? durationSeconds;
  final FeedContentType? contentType;
  final List<Product> products;
  final DateTime? createdAt;
  final String? ownerId;
  final String? ownerName;
  final String? ownerAvatarUrl;

  Product? get product => products.isEmpty ? null : products.first;
  String get id => product?.id ?? videoId;
  String? get categoryId => product?.categoryId;
  String? get cityId => product?.cityId;
  String? get subcategoryId => product?.subcategoryId;
  double? get latitude => product?.latitude;
  double? get longitude => product?.longitude;
  String? get videoUrl =>
      VideoUrlResolver.selectPlaybackUrl(hlsUrl: hlsUrl, rawUrl: rawUrl);

  FeedItem copyWith({List<Product>? products}) => FeedItem(
    videoId: videoId,
    thumbnailUrl: thumbnailUrl,
    hlsUrl: hlsUrl,
    rawUrl: rawUrl,
    durationSeconds: durationSeconds,
    contentType: contentType,
    products: products ?? this.products,
    createdAt: createdAt,
    ownerId: ownerId,
    ownerName: ownerName,
    ownerAvatarUrl: ownerAvatarUrl,
  );

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
    videoId: '${json['videoId'] ?? json['id'] ?? ''}',
    thumbnailUrl: json['thumbnailUrl'] as String?,
    hlsUrl: json['hlsUrl'] as String?,
    rawUrl: json['rawUrl'] as String? ?? json['url'] as String?,
    durationSeconds: json['durationSeconds'] as int?,
    contentType: json['contentType'] == null
        ? null
        : FeedContentType.fromCode(json['contentType'] as String?),
    products: _products(json),
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    ownerId: json['ownerId'] as String?,
    ownerName: json['ownerName'] as String?,
    ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
  );

  static List<Product> _products(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    if (rawProducts is List) {
      return rawProducts
          .whereType<Map>()
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }

    if (json['product'] is Map) {
      return [
        Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      ];
    }
    if (json.containsKey('title')) return [Product.fromJson(json)];
    return const [];
  }
}
