import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store_statistics.dart';
import 'package:vidsell/models/store/store_stats.dart';
import 'package:vidsell/models/store/public_store_profile.dart';

class MockBusinessRepository implements BusinessRepository {
  MockBusinessRepository._();

  static final instance = MockBusinessRepository._();

  StoreDraft? _currentDraft;
  MyStore? _myStore;

  @override
  StoreDraft? get currentDraft => _currentDraft;

  @override
  Future<MyStore> createStoreApplication(StoreDraft draft) async {
    if (draft.storeName.trim().isEmpty ||
        draft.description.trim().isEmpty ||
        draft.categoryNames.isEmpty ||
        draft.email.trim().isEmpty ||
        draft.mainPhone.trim().isEmpty) {
      throw ArgumentError('Bütün vacib sahələri doldurun');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _currentDraft = draft;
    _myStore = MyStore(
      id: 'store-${DateTime.now().millisecondsSinceEpoch}',
      name: draft.storeName.trim(),
      category: draft.categoryNames.first,
      description: draft.description,
      phone: draft.mainPhone,
      workingHours: '${draft.openingTime}-${draft.closingTime}',
      status: 'APPLICATION',
      isOpen: false,
      logoUrl: draft.logoPath,
      stats: const StoreStats(products: 0, views: 0, followers: 0),
    );
    return _myStore!;
  }

  @override
  Future<MyStore> updateMyStore(StoreDraft draft) async {
    final existing = _myStore;
    if (existing == null) throw StateError('Mağaza tapılmadı.');
    _currentDraft = draft;
    _myStore = MyStore(
      id: existing.id,
      name: draft.storeName.trim(),
      category: draft.categoryNames.firstOrNull ?? existing.category,
      description: draft.description,
      phone: draft.mainPhone.trim().isEmpty
          ? draft.phoneNumber
          : draft.mainPhone,
      workingHours: '${draft.openingTime}-${draft.closingTime}',
      status: existing.status,
      isOpen: existing.isOpen,
      logoUrl: draft.logoPath,
      rejectionReason: existing.rejectionReason,
      reviewedAt: existing.reviewedAt,
      createdAt: existing.createdAt,
      stats: existing.stats,
      openUntil: existing.openUntil,
    );
    return _myStore!;
  }

  @override
  Future<MyStore> deactivateMyStore() => _setStatus('INACTIVE');

  @override
  Future<MyStore> reactivateMyStore() => _setStatus('ACTIVE');

  Future<MyStore> _setStatus(String status) async {
    final store = _myStore;
    if (store == null) throw StateError('Mağaza tapılmadı.');
    _myStore = MyStore(
      id: store.id,
      name: store.name,
      category: store.category,
      description: store.description,
      phone: store.phone,
      workingHours: store.workingHours,
      status: status,
      isOpen: store.isOpen,
      logoUrl: store.logoUrl,
      rejectionReason: store.rejectionReason,
      reviewedAt: store.reviewedAt,
      createdAt: store.createdAt,
      stats: store.stats,
      openUntil: store.openUntil,
    );
    return _myStore!;
  }

  @override
  Future<void> deleteMyStore() async {
    _myStore = null;
    _currentDraft = null;
  }

  @override
  Future<MyStore?> fetchMyStore() async => _myStore;

  @override
  Future<PublicStoreProfile?> fetchPublicStore(String sellerId) async {
    final store = _myStore;
    if (store == null) throw StateError('Mağaza tapılmadı.');
    return PublicStoreProfile(
      sellerId: sellerId,
      storeName: store.name,
      category: store.category,
      description: store.description,
      logoUrl: store.logoUrl,
      open24Hours: store.openUntil == null,
      opensAt: store.workingHours.split('-').firstOrNull,
      closesAt: store.workingHours.split('-').lastOrNull,
      products: store.stats?.products,
      views: store.stats?.views,
      followers: store.stats?.followers,
    );
  }

  @override
  Future<List<Product>> fetchPublicStoreProducts(
    String sellerId, {
    int page = 1,
  }) async => const [];

  @override
  Future<StoreStatistics> fetchMyStoreStatistics() async =>
      const StoreStatistics(views: 1240, listings: 31, followers: 14);
}
