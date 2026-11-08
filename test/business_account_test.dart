import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/models/business_account.dart';
import 'package:vidsell/features/discover/repositories/mock_business_repository.dart';

void main() {
  test('mock business repository creates pending application', () async {
    final account = await MockBusinessRepository.instance.createBusiness(
      const BusinessAccountDraft(
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

    expect(account.status, 'APPLICATION');
    expect(account.storeName, 'Test Store');
    expect(account.logoPath, '/tmp/test-logo.png');
    expect(account.bannerPath, '/tmp/test-banner.png');
    expect(account.description, 'Reliable electronics and personal service.');
    expect(account.city, 'Bakı');
    expect(account.address, 'Nizami küçəsi 10');
    expect(account.email, 'test@example.com');
    expect(account.mainPhone, '+994501234567');
    expect(account.openDays, ['Bazar ertəsi']);
    expect(account.openingTime, '10:00');
    expect(account.closingTime, '18:00');
    expect(MockBusinessRepository.instance.currentBusiness?.id, account.id);
    expect(MockBusinessRepository.instance.currentBusinessCreatedAt, isNotNull);
  });

  test('mock business repository rejects incomplete application', () {
    expect(
      () => MockBusinessRepository.instance.createBusiness(
        const BusinessAccountDraft(phoneNumber: '+994501234567'),
      ),
      throwsArgumentError,
    );
  });

  test(
    'mock business analytics returns selected period and daily counts',
    () async {
      final repository = MockBusinessRepository.instance;

      final week = await repository.fetchAnalytics('business-1', period: '7d');
      final month = await repository.fetchAnalytics(
        'business-1',
        period: '30d',
      );

      expect(week.period, '7d');
      expect(week.viewsByDay, hasLength(7));
      expect(
        week.viewsByDay.fold<int>(0, (sum, value) => sum + value),
        week.views,
      );
      expect(month.period, '30d');
      expect(
        month.searchesByDay.fold<int>(0, (sum, value) => sum + value),
        month.searches,
      );
      expect(
        month.messagesByDay.fold<int>(0, (sum, value) => sum + value),
        month.messages,
      );
    },
  );

  test('mock business repository updates store profile details', () async {
    final repository = MockBusinessRepository.instance;
    final account = await repository.createBusiness(
      const BusinessAccountDraft(
        phoneNumber: '+994501234567',
        storeName: 'Original store',
        slogan: 'Original slogan',
        description: 'Original description',
        categoryNames: ['Elektronik'],
        email: 'original@example.com',
        mainPhone: '+994501234567',
      ),
    );

    final updated = await repository.updateBusiness(
      account.id,
      const BusinessAccountDraft(
        phoneNumber: '+994501234567',
        storeName: 'Updated store',
        slogan: 'Updated slogan',
        description: 'Updated description',
        categoryNames: ['Emlak'],
        city: 'Gəncə',
        address: 'Mərkəz küçəsi 5',
        email: 'updated@example.com',
        mainPhone: '+994501111111',
      ),
    );

    expect(updated.id, account.id);
    expect(updated.storeName, 'Updated store');
    expect(updated.city, 'Gəncə');
    expect(updated.address, 'Mərkəz küçəsi 5');
    expect(repository.currentBusiness, updated);
    final deactivated = await repository.updateBusiness(
      updated.id,
      const BusinessAccountDraft(
        phoneNumber: '+994501234567',
        storeName: 'Updated store',
        isActive: false,
      ),
    );
    expect(deactivated.isActive, isFalse);
  });

  test('mock business repository deletes store account', () async {
    final repository = MockBusinessRepository.instance;
    final account = await repository.createBusiness(
      const BusinessAccountDraft(
        phoneNumber: '+994501234567',
        storeName: 'Store to delete',
        slogan: 'Slogan',
        description: 'Description',
        categoryNames: ['Elektronik'],
        email: 'store@example.com',
        mainPhone: '+994501234567',
      ),
    );

    await repository.deleteBusiness(account.id);

    expect(repository.currentBusiness, isNull);
    expect(repository.currentBusinessCreatedAt, isNull);
  });
}
