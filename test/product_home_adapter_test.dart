import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/adapters/product_legacy_adapter.dart';
import 'package:vidsell/features/home/models/home_listing.dart';

void main() {
  test(
    'converts home listing IDs and preserves unavailable map coordinates',
    () {
      final product = ProductLegacyAdapter.fromHomeListing(
        const HomeListing(
          id: 'listing-42',
          sellerName: 'Seller',
          sellerHandle: '@seller',
          sellerId: 'seller-7',
          price: '100 AZN',
          title: 'Camera',
          shareLink: '',
          isVip: true,
        ),
      );

      expect(product.id, 'listing-42');
      expect(product.sellerId, 'seller-7');
      expect(product.isVip, isTrue);
      expect(product.latitude, isNull);
      expect(product.longitude, isNull);
    },
  );
}
