import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';

void main() {
  test('favorite listing retains video URL and its thumbnail', () {
    final item = EngagementItem.fromJson({
      'listing': {
        'id': 'listing-1',
        'title': 'Video listing',
        'price': '100 AZN',
        'media': [
          {
            'url': 'https://cdn.example.test/listing.mp4',
            'type': 'video',
            'thumbnailUrl': 'https://cdn.example.test/listing-thumb.jpg',
          },
        ],
      },
    });

    expect(item.id, 'listing-1');
    expect(item.videoUrl, 'https://cdn.example.test/listing.mp4');
    expect(item.imageUrl, 'https://cdn.example.test/listing-thumb.jpg');
  });

  test('favorite listing prefers image media for its card thumbnail', () {
    final item = EngagementItem.fromJson({
      'listing': {
        'id': 'listing-2',
        'title': 'Photo and video listing',
        'media': [
          {'url': 'https://cdn.example.test/listing.mp4', 'type': 'video'},
          {'url': 'https://cdn.example.test/listing.jpg', 'type': 'image'},
        ],
      },
    });

    expect(item.videoUrl, 'https://cdn.example.test/listing.mp4');
    expect(item.imageUrl, 'https://cdn.example.test/listing.jpg');
  });
}
