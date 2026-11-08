import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/home/repositories/listing_detail_repository.dart';
import 'package:vidsell/models/product/product.dart';

class ApiListingDetailRepository implements ListingDetailRepository {
  ApiListingDetailRepository(this._client);

  final ApiClient _client;

  @override
  Future<Product> fetchListing(String listingId) async {
    final data = await _client.get('/listings/$listingId');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid listing detail response.');
    }
    return Product.fromJson(data);
  }
}
