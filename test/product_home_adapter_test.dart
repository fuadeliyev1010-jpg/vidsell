import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/models/video/feed_item.dart';

void main() {
  test('feed cards use the first Product and tolerate empty product lists', () {
    final firstProduct = FeedItem.fromJson({
      'videoId': 'video-with-products',
      'products': [
        {'id': 'first', 'title': 'First product', 'price': 100},
        {'id': 'second', 'title': 'Second product', 'price': 200},
      ],
    });
    final noProduct = FeedItem.fromJson({
      'videoId': 'video-without-products',
      'products': [],
    });

    expect(firstProduct.product?.id, 'first');
    expect(firstProduct.products, hasLength(2));
    expect(noProduct.product, isNull);
    expect(noProduct.id, 'video-without-products');
  });
}
