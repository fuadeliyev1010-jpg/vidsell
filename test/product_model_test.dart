import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/models/product/product.dart';

void main() {
  Product parse(dynamic imageUrls) => Product.fromJson({
    'id': 'product-1',
    'title': 'Phone',
    'price': 100,
    'imageUrls': imageUrls,
  });

  test(
    'decodes imageUrls from JSON strings, plain URLs, and request-style lists',
    () {
      expect(parse(null).imageUrls, isEmpty);
      expect(parse('[]').imageUrls, isEmpty);
      expect(parse('["https://example.com/image.jpg"]').imageUrls, [
        'https://example.com/image.jpg',
      ]);
      expect(parse('https://example.com/image.jpg').imageUrls, [
        'https://example.com/image.jpg',
      ]);
      expect(parse(['https://example.com/image.jpg']).imageUrls, [
        'https://example.com/image.jpg',
      ]);
    },
  );

  test('parses localized labels and uses them for display', () {
    final product = Product.fromJson({
      'id': 'product-1',
      'title': 'Phone',
      'price': 100,
      'category': 'ELECTRONICS',
      'categoryLabel': 'Elektronik',
      'subcategoryName': 'Phones',
      'subcategoryLabel': 'Telefonlar',
      'condition': 'NEW',
      'conditionLabel': 'Yeni',
      'status': 'ACTIVE',
      'statusLabel': 'Aktif',
      'promotionType': 'VIP',
      'promotionTypeLabel': 'VIP ilan',
      'sellerType': 'STORE',
      'sellerTypeLabel': 'Mağaza',
      'deliveryType': 'SHIPPING',
      'deliveryTypeLabel': 'Kargo',
    });

    expect(product.categoryLabel, 'Elektronik');
    expect(product.subcategoryLabel, 'Telefonlar');
    expect(product.conditionLabel, 'Yeni');
    expect(product.statusLabel, 'Aktif');
    expect(product.promotionTypeLabel, 'VIP ilan');
    expect(product.sellerTypeLabel, 'Mağaza');
    expect(product.deliveryTypeLabel, 'Kargo');
    expect(product.categoryDisplay, 'Elektronik');
    expect(product.subcategoryDisplay, 'Telefonlar');
    expect(product.conditionDisplay, 'Yeni');
    expect(product.statusDisplay, 'Aktif');
    expect(product.promotionDisplay, 'VIP ilan');
    expect(product.sellerTypeDisplay, 'Mağaza');
    expect(product.deliveryTypeDisplay, 'Kargo');

    final json = product.toJson();
    expect(json['categoryLabel'], 'Elektronik');
    expect(json['deliveryTypeLabel'], 'Kargo');
  });

  test('parses responses without labels and falls back to enum codes', () {
    final product = Product.fromJson({
      'id': 'product-1',
      'title': 'Phone',
      'price': 100,
      'category': 'ELECTRONICS',
      'condition': 'NEW',
      'status': 'ACTIVE',
      'promotionType': 'VIP',
      'sellerType': 'STORE',
      'deliveryType': 'SHIPPING',
    });

    expect(product.categoryLabel, isNull);
    expect(product.subcategoryLabel, isNull);
    expect(product.conditionLabel, isNull);
    expect(product.statusLabel, isNull);
    expect(product.promotionTypeLabel, isNull);
    expect(product.sellerTypeLabel, isNull);
    expect(product.deliveryTypeLabel, isNull);
    expect(product.categoryDisplay, 'ELECTRONICS');
    expect(product.subcategoryDisplay, isEmpty);
    expect(product.conditionDisplay, 'NEW');
    expect(product.statusDisplay, 'ACTIVE');
    expect(product.promotionDisplay, 'VIP');
    expect(product.sellerTypeDisplay, 'STORE');
    expect(product.deliveryTypeDisplay, 'SHIPPING');
  });
}
