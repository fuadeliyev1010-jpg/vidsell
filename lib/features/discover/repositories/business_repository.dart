import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/models/store/store_statistics.dart';

abstract interface class BusinessRepository {
  StoreDraft? get currentDraft;

  Future<MyStore> createStoreApplication(StoreDraft draft);
  Future<MyStore> updateMyStore(StoreDraft draft);
  Future<MyStore> deactivateMyStore();
  Future<MyStore> reactivateMyStore();
  Future<void> deleteMyStore();
  Future<MyStore?> fetchMyStore();
  Future<Store> fetchPublicStore(String sellerId);
  Future<List<Product>> fetchPublicStoreProducts(
    String sellerId, {
    int page = 1,
  });
  Future<StoreStatistics> fetchMyStoreStatistics();
}
