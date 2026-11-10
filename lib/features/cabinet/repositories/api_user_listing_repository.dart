import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/product.dart';

class ApiUserListingRepository implements UserListingRepository {
  ApiUserListingRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Product>> fetchMyListings({ProductStatus? status}) async {
    final data = await _client.get(
      '/products/me',
      queryParameters: {if (status != null) 'status': status.code},
    );
    return parsePage(data, Product.fromJson).items;
  }

  @override
  Future<void> updateListingStatus(
    String listingId,
    ProductStatus status,
  ) async {
    switch (status) {
      case ProductStatus.active:
        await _client.post('/products/$listingId/activate');
      case ProductStatus.sold:
        await _client.post('/products/$listingId/deactivate');
      default:
        throw ArgumentError(
          'Only active and sold products can change status from the cabinet.',
        );
    }
  }

  @override
  Future<void> deleteListing(String listingId) async {
    await _client.delete('/products/$listingId');
  }
}
