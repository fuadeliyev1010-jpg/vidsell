import '../../core/utils/video_url_resolver.dart';
import '../enums/video_status.dart';

class Video {
  const Video({
    required this.id,
    required this.ownerId,
    this.status,
    this.hlsUrl,
    this.rawUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.productIds = const [],
  });

  final String id;
  final String ownerId;
  final VideoStatus? status;
  final String? hlsUrl;
  final String? rawUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final List<String> productIds;

  String? get playbackUrl =>
      VideoUrlResolver.selectPlaybackUrl(hlsUrl: hlsUrl, rawUrl: rawUrl);

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    id: '${json['id'] ?? ''}',
    ownerId: '${json['ownerId'] ?? ''}',
    status: json['status'] == null
        ? null
        : VideoStatus.fromCode(json['status'] as String?),
    hlsUrl: json['hlsUrl'] as String? ?? json['url'] as String?,
    rawUrl: json['rawUrl'] as String? ?? json['url'] as String?,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
    productIds: json['productIds'] is List
        ? (json['productIds'] as List).map((value) => '$value').toList()
        : const [],
  );
}
