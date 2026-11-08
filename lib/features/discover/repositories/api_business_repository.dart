import 'package:dio/dio.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/discover/models/business_account.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/models/store/store_application_request.dart';
import 'package:vidsell/models/product/product.dart';
import 'package:vidsell/models/store/my_store.dart';
import 'package:vidsell/models/store/store.dart';

class ApiBusinessRepository implements BusinessRepository {
  ApiBusinessRepository(this._client);

  final ApiClient _client;

  @override
  BusinessAccount? currentBusiness;

  @override
  DateTime? currentBusinessCreatedAt;

  @override
  Future<BusinessAccount> createBusiness(BusinessAccountDraft draft) async {
    final application = StoreApplicationRequest(
      name: draft.storeName,
      category: draft.categoryNames.join(','),
      description: draft.description,
      phone: draft.mainPhone.isEmpty ? draft.phoneNumber : draft.mainPhone,
      workingHours: '${draft.openingTime}-${draft.closingTime}',
    );
    final data = await _client.post(
      '/business-accounts',
      data: {
        ...application.toJson(),
        'phoneNumber': draft.phoneNumber,
        'storeName': draft.storeName,
        'slogan': draft.slogan,
        'description': draft.description,
        'categoryNames': draft.categoryNames,
        'city': draft.city,
        'address': draft.address,
        'logoPath': draft.logoPath,
        'bannerPath': draft.bannerPath,
        'alwaysOpen': draft.alwaysOpen,
        'openDays': draft.openDays,
        'openingTime': draft.openingTime,
        'closingTime': draft.closingTime,
        'email': draft.email,
        'mainPhone': draft.mainPhone,
        'additionalPhones': draft.additionalPhones,
        'shortNumber': draft.shortNumber,
        'isActive': draft.isActive,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid business account response.');
    }
    final account = BusinessAccount.fromJson({
      ...data,
      'storeName': data['storeName'] ?? draft.storeName,
      'phoneNumber': data['phoneNumber'] ?? draft.phoneNumber,
    });
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
    final application = StoreApplicationRequest(
      name: draft.storeName,
      category: draft.categoryNames.join(','),
      description: draft.description,
      phone: draft.mainPhone.isEmpty ? draft.phoneNumber : draft.mainPhone,
      workingHours: '${draft.openingTime}-${draft.closingTime}',
    );
    final payload = <String, dynamic>{
      ...application.toJson(),
      'phoneNumber': draft.phoneNumber,
      'storeName': draft.storeName,
      'slogan': draft.slogan,
      'description': draft.description,
      'categoryNames': draft.categoryNames,
      'logoPath': draft.logoPath,
      'bannerPath': draft.bannerPath,
      'city': draft.city,
      'address': draft.address,
      'alwaysOpen': draft.alwaysOpen,
      'openDays': draft.openDays,
      'openingTime': draft.openingTime,
      'closingTime': draft.closingTime,
      'email': draft.email,
      'mainPhone': draft.mainPhone,
      'additionalPhones': draft.additionalPhones,
      'shortNumber': draft.shortNumber,
      'isActive': draft.isActive,
    };
    if (password != null && password.isNotEmpty) payload['password'] = password;

    final data = await _client.patch(
      '/business-accounts/$businessId',
      data: payload,
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid business account response.');
    }
    final account = BusinessAccount.fromJson({
      ...data,
      'id': data['id'] ?? businessId,
      'storeName': data['storeName'] ?? draft.storeName,
      'phoneNumber': data['phoneNumber'] ?? draft.phoneNumber,
    });
    currentBusiness = account;
    return account;
  }

  @override
  Future<void> deleteBusiness(String businessId) async {
    await _client.delete('/business-accounts/$businessId');
    if (currentBusiness?.id == businessId) {
      currentBusiness = null;
      currentBusinessCreatedAt = null;
    }
  }

  @override
  Future<BusinessAccount> fetchBusiness(String businessId) async {
    final data = await _client.get('/business-accounts/$businessId');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid business account response.');
    }
    return BusinessAccount.fromJson(data);
  }

  @override
  Future<BusinessVerification> submitVerification(
    String businessId, {
    required String documentPath,
  }) async {
    final data = await _client.postMultipart(
      '/business-accounts/$businessId/verification',
      data: FormData.fromMap({
        'document': await MultipartFile.fromFile(documentPath),
      }),
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid verification response.');
    }
    return BusinessVerification.fromJson(data);
  }

  @override
  Future<List<BusinessListing>> fetchBusinessListings(String businessId) async {
    final data = await _client.get('/business-accounts/$businessId/listings');
    return parsePage(data, BusinessListing.fromJson).items;
  }

  @override
  Future<BusinessAnalytics> fetchAnalytics(
    String businessId, {
    String period = '7d',
  }) async {
    final data = await _client.get(
      '/business-accounts/$businessId/analytics',
      queryParameters: {'period': period},
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid business analytics response.');
    }
    return BusinessAnalytics.fromJson(data);
  }

  @override
  Future<MyStore?> fetchMyStore() async {
    final data = await _client.get('/storefronts/me');
    if (data == null) return null;
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid store response.');
    }
    return MyStore.fromJson(data);
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
  Future<MyStore> fetchMyStoreStatistics(MyStore store) async {
    final data = await _client.get('/storefronts/me/statistics');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid store statistics response.');
    }
    final statsData = data['stats'] is Map
        ? Map<String, dynamic>.from(data['stats'] as Map)
        : data;
    return MyStore.fromJson({...store.toJson(), 'stats': statsData});
  }
}
