import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';

void main() {
  test('parses Store with optional fields and exposes display getters', () {
    final store = Store.fromJson({
      'id': 'seller-1',
      'name': 'Demo Store',
      'category': 'ELECTRONICS',
      'logoUrl': 'https://example.com/logo.png',
      'description': 'About',
      'phone': '+994500000000',
      'workingHours': '09:00-18:00',
      'status': 'ACTIVE',
      'isOpen': true,
      'openUntil': '18:00',
      'stats': {'products': 3, 'views': 20, 'followers': 4},
    });

    expect(store.displayName, 'Demo Store');
    expect(store.categoryDisplay, 'ELECTRONICS');
    expect(store.phoneDisplay, '+994500000000');
    expect(store.workingHoursDisplay, '09:00-18:00');
    expect(store.statusDisplay, 'ACTIVE');
    expect(store.stats?.products, 3);
    expect(store.isOpen, isTrue);
  });

  test('parses Store and MyStore without optional fields', () {
    final store = Store.fromJson({'id': 'seller-1', 'name': 'Store'});
    final myStore = MyStore.fromJson({
      'name': 'My Store',
      'category': 'SERVICES',
      'description': '',
      'phone': '',
      'workingHours': '',
      'status': 'APPLICATION',
      'isOpen': false,
    });

    expect(store.logoUrl, isNull);
    expect(store.stats, isNull);
    expect(store.displayName, 'Store');
    expect(myStore.logoUrl, isNull);
    expect(myStore.rejectionReason, isNull);
    expect(myStore.displayName, 'My Store');
    expect(myStore.statusDisplay, 'APPLICATION');
    expect(myStore.isOpen, isFalse);
  });
}
