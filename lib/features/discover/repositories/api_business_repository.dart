import 'package:vidsell/core/network/api_exception.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/discover/models/store_draft.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';
import 'package:vidsell/models/store/store_application_request.dart';
import 'package:vidsell/models/store/store_statistics.dart';
import 'package:vidsell/models/store/update_store_request.dart';

class ApiBusinessRepository implements BusinessRepository {
  ApiBusinessRepository(this._client);

  final ApiClient _client;

  @override
  StoreDraft? get currentDraft => null;

  @override
  Future<MyStore> createStoreApplication(StoreDraft draft) async {
    final data = await _client.post(
      '/storefronts/me/application',
      data: StoreApplicationRequest(
        name: draft.storeName.trim(),
        category: draft.categoryNames.firstOrNull ?? '',
        description: draft.description.trim(),
        phone: draft.mainPhone.trim().isEmpty
            ? draft.phoneNumber.trim()
            : draft.mainPhone.trim(),
        workingHours: '${draft.openingTime}-${draft.closingTime}',
      ).toJson(),
    );
    return _myStoreFromMutationResponse(data);
  }

  @override
  Future<MyStore> updateMyStore(StoreDraft draft) async {
    final request = UpdateStoreRequest(
      name: draft.storeName.trim(),
      category: draft.categoryNames.firstOrNull,
      description: draft.description.trim(),
      phone: draft.mainPhone.trim().isEmpty
          ? draft.phoneNumber.trim()
          : draft.mainPhone.trim(),
      workingHours: '${draft.openingTime}-${draft.closingTime}',
    );
    final data = await _client.put('/storefronts/me', data: request.toJson());
    return _myStoreFromMutationResponse(data);
  }

  @override
  Future<MyStore> deactivateMyStore() =>
      _updateStatus('/storefronts/me/deactivate');

  @override
  Future<MyStore> reactivateMyStore() =>
      _updateStatus('/storefronts/me/reactivate');

  Future<MyStore> _updateStatus(String path) async {
    final data = await _client.post(path);
    return _myStoreFromMutationResponse(data);
  }

  Future<MyStore> _myStoreFromMutationResponse(Object? data) async {
    if (data is Map<String, dynamic>) return MyStore.fromJson(data);
    if (data != null && data != '') {
      throw StateError('Invalid store response.');
    }
    final store = await fetchMyStore();
    if (store == null) {
      throw StateError('Store mutation succeeded but no store was returned.');
    }
    return store;
  }

  @override
  Future<void> deleteMyStore() =>
      throw UnsupportedError('Store deletion is not supported by the API.');

  @override
  Future<MyStore?> fetchMyStore() async {
    try {
      final data = await _client.get('/storefronts/me');
      if (data == null) return null;
      if (data is! Map<String, dynamic>) {
        throw StateError('Invalid store response.');
      }
      return MyStore.fromJson(data);
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Store> fetchPublicStore(String sellerId) async {
    final data = await _client.get('/storefronts/$sellerId');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid store response.');
    }
    return Store.fromJson(data);
  }

  @override
  Future<List<Product>> fetchPublicStoreProducts(
    String sellerId, {
    int page = 1,
  }) async {
    final data = await _client.get(
      '/storefronts/$sellerId/products',
      queryParameters: {'page': page},
    );
    return parsePage(data, Product.fromJson).items;
  }

  @override
  Future<StoreStatistics> fetchMyStoreStatistics() async {
    final data = await _client.get('/storefronts/me/statistics');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid store statistics response.');
    }
    return StoreStatistics.fromJson(data);
  }
}
