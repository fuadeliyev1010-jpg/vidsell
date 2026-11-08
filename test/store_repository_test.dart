import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/features/discover/repositories/mock_business_repository.dart';

void main() {
  final repository = MockBusinessRepository.instance;

  setUp(() async => repository.deleteMyStore());

  test(
    'mock repository creates an owner store and preserves mock-only fields',
    () async {
      final store = await repository.createStoreApplication(
        const StoreDraft(
          phoneNumber: '+994501234567',
          storeName: 'Test Store',
          slogan: 'Quality electronics',
          description: 'Reliable electronics and personal service.',
          categoryNames: ['Elektronika'],
          city: 'Bakı',
          address: 'Nizami küçəsi 10',
          logoPath: '/tmp/test-logo.png',
          bannerPath: '/tmp/test-banner.png',
          openDays: ['Bazar ertəsi'],
          openingTime: '10:00',
          closingTime: '18:00',
          email: 'test@example.com',
          mainPhone: '+994501234567',
        ),
      );

      expect(store.status, 'APPLICATION');
      expect(store.name, 'Test Store');
      expect(store.logoUrl, '/tmp/test-logo.png');
      expect(store.description, 'Reliable electronics and personal service.');
      expect(store.category, 'Elektronika');
      expect(repository.currentDraft?.bannerPath, '/tmp/test-banner.png');
      expect(repository.currentDraft?.city, 'Bakı');
      expect(repository.currentDraft?.address, 'Nizami küçəsi 10');
      expect(repository.currentDraft?.email, 'test@example.com');
      expect(repository.currentDraft?.openDays, ['Bazar ertəsi']);
    },
  );

  test('mock repository rejects incomplete store application', () {
    expect(
      () => repository.createStoreApplication(
        const StoreDraft(phoneNumber: '+994501234567'),
      ),
      throwsArgumentError,
    );
  });

  test(
    'mock repository updates store and follows documented status flow',
    () async {
      final store = await repository.createStoreApplication(
        const StoreDraft(
          phoneNumber: '+994501234567',
          storeName: 'Original store',
          description: 'Original description',
          categoryNames: ['Elektronik'],
          email: 'original@example.com',
          mainPhone: '+994501234567',
        ),
      );

      final updated = await repository.updateMyStore(
        const StoreDraft(
          phoneNumber: '+994501234567',
          storeName: 'Updated store',
          description: 'Updated description',
          categoryNames: ['Emlak'],
          city: 'Gəncə',
          address: 'Mərkəz küçəsi 5',
          email: 'updated@example.com',
          mainPhone: '+994501111111',
        ),
      );
      expect(updated.id, store.id);
      expect(updated.name, 'Updated store');
      expect(updated.category, 'Emlak');
      expect(updated.phone, '+994501111111');
      expect(repository.currentDraft?.city, 'Gəncə');

      final deactivated = await repository.deactivateMyStore();
      expect(deactivated.status, 'INACTIVE');
      final reactivated = await repository.reactivateMyStore();
      expect(reactivated.status, 'ACTIVE');
    },
  );

  test('mock repository returns documented statistics fields', () async {
    final statistics = await repository.fetchMyStoreStatistics();

    expect(statistics.views, 1240);
    expect(statistics.listings, 31);
    expect(statistics.followers, 14);
  });

  test('mock repository deletes store only in mock mode', () async {
    await repository.createStoreApplication(
      const StoreDraft(
        phoneNumber: '+994501234567',
        storeName: 'Store to delete',
        slogan: 'Slogan',
        description: 'Description',
        categoryNames: ['Elektronik'],
        email: 'store@example.com',
        mainPhone: '+994501234567',
      ),
    );

    await repository.deleteMyStore();

    expect(repository.fetchMyStore(), completion(isNull));
    expect(repository.currentDraft, isNull);
  });
}
