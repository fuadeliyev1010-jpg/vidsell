import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/adapters/product_legacy_adapter.dart';
import 'package:vidsell/core/utils/video_url_resolver.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
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

    expect(
      ProductLegacyAdapter.toHomeListingFromFeedItem(hlsItem).videoUrl,
      'https://cdn.example.test/video.m3u8',
    );
    expect(
      ProductLegacyAdapter.toHomeListingFromFeedItem(rawOnlyItem).videoUrl,
      'https://cdn.example.test/raw.mp4',
    );
    expect(
      ProductLegacyAdapter.toHomeListingFromFeedItem(noSourceItem).videoUrl,
      isNull,
    );
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
