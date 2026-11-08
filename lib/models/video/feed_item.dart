import '../../core/utils/video_url_resolver.dart';
import '../enums/feed_content_type.dart';
import '../product/product.dart';
import '../product/product_summary.dart';

class FeedItem {
  const FeedItem({
    required this.videoId,
    this.thumbnailUrl,
    this.hlsUrl,
    this.rawUrl,
    this.durationSeconds,
    this.contentType,
    this.products = const [],
    this.ownerId,
    this.ownerName,
    this.ownerAvatarUrl,
    this.product,
  });

  final String videoId;
  final String? thumbnailUrl;
  final String? hlsUrl;
  final String? rawUrl;
  final int? durationSeconds;
  final FeedContentType? contentType;
  final List<ProductSummary> products;
  final String? ownerId;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final Product? product;

  String get id => product?.id ?? videoId;
  String? get categoryId => product?.categoryId;
  String? get cityId => product?.cityId;
  String? get subcategoryId => product?.subcategoryId;
  double? get latitude => product?.latitude;
  double? get longitude => product?.longitude;
  String? get videoUrl =>
      VideoUrlResolver.selectPlaybackUrl(hlsUrl: hlsUrl, rawUrl: rawUrl);

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
    videoId: '${json['videoId'] ?? json['id'] ?? ''}',
    thumbnailUrl: json['thumbnailUrl'] as String?,
    hlsUrl: json['hlsUrl'] as String?,
    rawUrl: json['rawUrl'] as String? ?? json['url'] as String?,
    durationSeconds: json['durationSeconds'] as int?,
    contentType: json['contentType'] == null
        ? null
        : FeedContentType.fromCode(json['contentType'] as String?),
    products: json['products'] is List
        ? (json['products'] as List)
              .whereType<Map>()
              .map(
                (item) =>
                    ProductSummary.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
        : const [],
    ownerId: json['ownerId'] as String?,
    ownerName: json['ownerName'] as String?,
    ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
    product: json['product'] is Map
        ? Product.fromJson(Map<String, dynamic>.from(json['product'] as Map))
        : (json.containsKey('title') ? Product.fromJson(json) : null),
  );
}
