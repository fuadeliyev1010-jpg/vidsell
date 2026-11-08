import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/utils/video_url_resolver.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
  test(
    'FeedItem card product uses first product and supports empty/many lists',
    () {
      final empty = FeedItem.fromJson({
        'videoId': 'empty',
        'products': [],
        'createdAt': '2026-01-02T03:04:05Z',
        'hlsUrl': 'https://cdn.example.test/video.m3u8',
        'thumbnailUrl': 'https://cdn.example.test/thumb.jpg',
        'durationSeconds': 12,
        'contentType': 'RECENT',
        'ownerId': 'seller-1',
        'ownerName': 'Seller',
        'ownerAvatarUrl': 'https://cdn.example.test/avatar.jpg',
      });
      final multiple = FeedItem.fromJson({
        'videoId': 'multiple',
        'products': [
          {'id': 'first', 'title': 'First', 'price': 1},
          {'id': 'second', 'title': 'Second', 'price': 2},
        ],
      });

      expect(empty.product, isNull);
      expect(empty.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
      expect(empty.durationSeconds, 12);
      expect(empty.contentType?.code, 'RECENT');
      expect(empty.ownerId, 'seller-1');
      expect(multiple.product?.id, 'first');
      expect(multiple.products, hasLength(2));
    },
  );

  test('feed playback prefers HLS and falls back to the raw URL', () {
    final hlsItem = FeedItem.fromJson({
      'videoId': 'hls-video',
      'hlsUrl': 'https://cdn.example.test/video.m3u8',
      'rawUrl': 'https://cdn.example.test/video.mp4',
    });
    final rawOnlyItem = FeedItem.fromJson({
      'videoId': 'raw-video',
      'rawUrl': 'https://cdn.example.test/raw.mp4',
    });
    final noSourceItem = FeedItem.fromJson({'videoId': 'no-video'});

    expect(hlsItem.videoUrl, 'https://cdn.example.test/video.m3u8');
    expect(rawOnlyItem.videoUrl, 'https://cdn.example.test/raw.mp4');
    expect(noSourceItem.videoUrl, isNull);
  });

  test(
    'empty HLS falls back to raw and relative URLs resolve against API base',
    () {
      final item = FeedItem.fromJson({
        'videoId': 'relative-video',
        'hlsUrl': ' ',
        'rawUrl': 'media/raw.mp4',
      });

      expect(item.videoUrl, 'media/raw.mp4');
      expect(
        VideoUrlResolver.resolveNetworkUrl(
          item.videoUrl,
          apiBaseUrl: 'https://api.example.test/api',
        ),
        Uri.parse('https://api.example.test/api/media/raw.mp4'),
      );
      expect(
        VideoUrlResolver.resolveNetworkUrl(
          '/media/raw.mp4',
          apiBaseUrl: 'https://api.example.test/api',
        ),
        Uri.parse('https://api.example.test/api/media/raw.mp4'),
      );
    },
  );
}
