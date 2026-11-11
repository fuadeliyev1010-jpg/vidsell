import 'package:vidsell/core/network/media_url.dart';

class EngagementItem {
  const EngagementItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.subtitle,
    this.videoUrl,
    this.categoryId,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final String subtitle;
  final String? videoUrl;
  final String? categoryId;

  factory EngagementItem.fromJson(
    Map<String, dynamic> json, {
    String? mediaOrigin,
  }) {
    final resource =
        _object(json['listing']) ??
        _object(json['store']) ??
        _object(json['item']) ??
        json;
    final rawId =
        json['listingId'] ?? json['storeId'] ?? json['id'] ?? resource['id'];
    if (rawId == null || '$rawId'.isEmpty) {
      throw const FormatException('Engagement response has no resource ID.');
    }

    return EngagementItem(
      id: '$rawId',
      title: _string(
        resource['title'] ??
            resource['name'] ??
            resource['fullName'] ??
            json['title'] ??
            json['name'] ??
            json['fullName'],
      ),
      imageUrl: _resolveMedia(
        _imageUrl(resource) ??
            _stringOrNull(json['imageUrl'] ?? json['avatarUrl']),
        mediaOrigin,
      ),
      subtitle: _string(
        resource['subtitle'] ??
            resource['handle'] ??
            resource['priceLabel'] ??
            resource['price'] ??
            json['subtitle'] ??
            json['handle'] ??
            json['price'],
      ),
      videoUrl: _resolveMedia(_videoUrl(resource), mediaOrigin),
      categoryId: _stringOrNull(resource['categoryId'] ?? json['categoryId']),
    );
  }

  static Map<String, dynamic>? _object(dynamic value) =>
      value is Map<String, dynamic> ? value : null;

  static String _string(dynamic value) => value is String
      ? value
      : value is num
      ? value.toString()
      : '';

  static String? _imageUrl(Map<String, dynamic> resource) {
    final image = _stringOrNull(
      resource['imageUrl'] ??
          resource['thumbnailUrl'] ??
          resource['avatarUrl'] ??
          resource['logoUrl'],
    );
    if (image != null) return image;
    final media = resource['media'];
    if (media is List) {
      for (final entry in media.whereType<Map>()) {
        final item = Map<String, dynamic>.from(entry);
        final url = _stringOrNull(item['url'] ?? item['imageUrl']);
        if (url == null) continue;
        if (_isVideo(item, url)) {
          final thumbnail = _stringOrNull(
            item['thumbnailUrl'] ?? item['thumbnail'],
          );
          if (thumbnail != null) return thumbnail;
          continue;
        }
        return url;
      }
    }
    return null;
  }

  static String? _videoUrl(Map<String, dynamic> resource) {
    final directUrl = _stringOrNull(resource['videoUrl']);
    if (directUrl != null) return directUrl;
    final media = resource['media'];
    if (media is! List) return null;
    for (final entry in media.whereType<Map>()) {
      final item = Map<String, dynamic>.from(entry);
      final url = _stringOrNull(item['url'] ?? item['videoUrl']);
      if (url != null && _isVideo(item, url)) return url;
    }
    return null;
  }

  static bool _isVideo(Map<String, dynamic> media, String url) {
    if (media['videoUrl'] is String) return true;
    final type = _string(media['type'] ?? media['mediaType']).toLowerCase();
    if (type == 'video') return true;
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return const ['.mp4', '.mov', '.m4v', '.webm', '.m3u8'].any(path.endsWith);
  }

  static String? _stringOrNull(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;

  static String? _resolveMedia(String? value, String? origin) =>
      origin == null ? value : resolveMediaUrl(value, origin: origin);
}
