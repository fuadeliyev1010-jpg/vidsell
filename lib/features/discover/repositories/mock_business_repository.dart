import 'package:vidsell/features/discover/models/business_account.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';
import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';

class MockBusinessRepository implements BusinessRepository {
  MockBusinessRepository._();

  static final instance = MockBusinessRepository._();

  @override
  BusinessAccount? currentBusiness;

  @override
  DateTime? currentBusinessCreatedAt;

  @override
  Future<BusinessAccount> createBusiness(BusinessAccountDraft draft) async {
    if (draft.storeName.trim().isEmpty ||
        draft.slogan.trim().isEmpty ||
        draft.description.trim().isEmpty ||
        draft.categoryNames.isEmpty ||
        draft.email.trim().isEmpty ||
        draft.mainPhone.trim().isEmpty) {
      throw ArgumentError('Bütün vacib sahələri doldurun');
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final account = BusinessAccount(
      id: 'business-${DateTime.now().millisecondsSinceEpoch}',
      status: 'APPLICATION',
      storeName: draft.storeName.trim(),
      phoneNumber: draft.phoneNumber,
      logoPath: draft.logoPath,
      bannerPath: draft.bannerPath,
      slogan: draft.slogan,
      description: draft.description,
      categoryNames: List.unmodifiable(draft.categoryNames),
      city: draft.city,
      address: draft.address,
      alwaysOpen: draft.alwaysOpen,
      openDays: List.unmodifiable(draft.openDays),
      openingTime: draft.openingTime,
      closingTime: draft.closingTime,
      email: draft.email,
      mainPhone: draft.mainPhone,
      additionalPhones: List.unmodifiable(draft.additionalPhones),
      shortNumber: draft.shortNumber,
      isActive: draft.isActive,
    );
    currentBusiness = account;
    currentBusinessCreatedAt = DateTime.now();
    return account;
  }

  @override
  Future<BusinessAccount> updateBusiness(
    String businessId,
    BusinessAccountDraft draft, {
    String? password,
  }) async {
    final existing = currentBusiness;
    if (existing == null || existing.id != businessId) {
      throw StateError('Mağaza hesabı tapılmadı.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final account = BusinessAccount(
      id: existing.id,
      status: existing.status,
      storeName: draft.storeName.trim(),
      phoneNumber: draft.phoneNumber,
      logoPath: draft.logoPath,
      bannerPath: draft.bannerPath,
      slogan: draft.slogan,
      description: draft.description,
      categoryNames: List.unmodifiable(draft.categoryNames),
      city: draft.city,
      address: draft.address,
      alwaysOpen: draft.alwaysOpen,
      openDays: List.unmodifiable(draft.openDays),
      openingTime: draft.openingTime,
      closingTime: draft.closingTime,
      email: draft.email,
      mainPhone: draft.mainPhone,
      additionalPhones: List.unmodifiable(draft.additionalPhones),
      shortNumber: draft.shortNumber,
      isActive: draft.isActive,
    );
    currentBusiness = account;
    return account;
  }

  @override
  Future<void> deleteBusiness(String businessId) async {
    if (currentBusiness?.id != businessId) {
      throw StateError('Mağaza hesabı tapılmadı.');
    }
    currentBusiness = null;
    currentBusinessCreatedAt = null;
  }

  @override
  Future<BusinessAccount> fetchBusiness(String businessId) async =>
      BusinessAccount(
        id: businessId,
        status: 'ACTIVE',
        storeName: 'Demo business',
        phoneNumber: '+994500000000',
      );

  @override
  Future<BusinessVerification> submitVerification(
    String businessId, {
    required String documentPath,
  }) async {
    if (documentPath.trim().isEmpty) {
      throw ArgumentError('Təsdiq sənədi seçilməyib');
    }
    return BusinessVerification(status: 'pending', submittedAt: DateTime.now());
  }

  @override
  Future<List<BusinessListing>> fetchBusinessListings(
    String businessId,
  ) async => const [
    BusinessListing(
      id: 'business-listing-1',
      title: 'Demo business listing',
      status: ListingStatus.active,
      views: 120,
      inquiries: 8,
    ),
  ];

  @override
  Future<BusinessAnalytics> fetchAnalytics(
    String businessId, {
    String period = '7d',
  }) async {
    if (period == '30d') {
      return const BusinessAnalytics(
        views: 8730,
        inquiries: 214,
        favorites: 96,
        period: '30d',
        searches: 214,
        messages: 96,
        viewsByDay: [950, 1220, 860, 1570, 1380, 1840, 910],
        searchesByDay: [24, 36, 21, 40, 31, 35, 27],
        messagesByDay: [10, 16, 13, 19, 15, 13, 10],
      );
    }
    return const BusinessAnalytics(
      views: 1240,
      inquiries: 31,
      favorites: 14,
      period: '7d',
      searches: 31,
      messages: 14,
      viewsByDay: [120, 180, 90, 210, 230, 260, 150],
      searchesByDay: [4, 5, 3, 6, 4, 5, 4],
      messagesByDay: [1, 2, 1, 3, 2, 3, 2],
    );
  }

  @override
  Future<MyStore?> fetchMyStore() async {
    final account = currentBusiness;
    if (account == null) return null;
    return MyStore.fromJson(account.toJson());
  }

  @override
  Future<Store> fetchPublicStore(String sellerId) async {
    final account = await fetchBusiness(sellerId);
    return Store.fromJson(account.toJson());
  }

  @override
  Future<List<Product>> fetchPublicStoreProducts(
    String sellerId, {
    int page = 1,
  }) async => const [];

  @override
  Future<MyStore> fetchMyStoreStatistics(MyStore store) async => store;
}
