import 'package:vidsell/features/discover/models/business_account.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';

abstract interface class BusinessRepository {
  BusinessAccount? get currentBusiness;
  DateTime? get currentBusinessCreatedAt;

  Future<BusinessAccount> createBusiness(BusinessAccountDraft draft);
  Future<BusinessAccount> updateBusiness(
    String businessId,
    BusinessAccountDraft draft, {
    String? password,
  });
  Future<void> deleteBusiness(String businessId);
  Future<BusinessAccount> fetchBusiness(String businessId);
  Future<BusinessVerification> submitVerification(
    String businessId, {
    required String documentPath,
  });
  Future<List<BusinessListing>> fetchBusinessListings(String businessId);
  Future<BusinessAnalytics> fetchAnalytics(
    String businessId, {
    String period = '7d',
  });

  Future<MyStore?> fetchMyStore();
  Future<Store> fetchPublicStore(String sellerId);
  Future<List<Product>> fetchPublicStoreProducts(
    String sellerId, {
    int page = 1,
  });
  Future<MyStore> fetchMyStoreStatistics(MyStore store);
}
