import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/network/media_url.dart';

void main() {
  const origin = 'http://localhost:8080';

  test('keeps absolute media URLs unchanged', () {
    const url = 'https://cdn.example.test/video.m3u8?quality=high';

    expect(resolveMediaUrl(url, origin: origin), url);
  });

  test('resolves leading and non-leading relative paths to the origin', () {
    expect(
      resolveMediaUrl('/uploads/videos/thumb.jpg', origin: origin),
      '$origin/uploads/videos/thumb.jpg',
    );
    expect(
      resolveMediaUrl('uploads/videos/thumb.jpg', origin: origin),
      '$origin/uploads/videos/thumb.jpg',
    );
  });

  test('returns null for null and empty inputs', () {
    expect(resolveMediaUrl(null, origin: origin), isNull);
    expect(resolveMediaUrl('', origin: origin), isNull);
    expect(resolveMediaUrl('  ', origin: origin), isNull);
  });

  test('strips API path and trailing slash when deriving the origin', () {
    expect(
      resolveMediaUrl(
        '/uploads/videos/thumb.jpg',
        apiBaseUrl: 'http://localhost:8080/api/v1/',
      ),
      'http://localhost:8080/uploads/videos/thumb.jpg',
    );
  });

  test('normalizes an injected origin with a trailing slash', () {
    expect(
      resolveMediaUrl('/uploads/videos/thumb.jpg', origin: '$origin/'),
      '$origin/uploads/videos/thumb.jpg',
    );
  });
}
