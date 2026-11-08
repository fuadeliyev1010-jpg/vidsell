import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/models/promotion/promotion_availability.dart';
import 'package:vidsell/models/product/promote_request.dart';
import 'package:vidsell/features/new_listing/repositories/promotion_repository.dart';

class ApiPromotionRepository implements PromotionRepository {
  ApiPromotionRepository(this._client);

  final ApiClient _client;

  @override
  Future<PromotionAvailability> fetchAvailability() async {
    final data = await _client.get('/promotions/availability');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid promotion availability response.');
    }
    return PromotionAvailability.fromJson(data);
  }

  @override
  Future<void> promoteProduct({
    required String productId,
    required PromoteRequest request,
  }) async {
    final data = await _client.post(
      '/products/$productId/promote',
      data: request.toJson(),
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid product promotion response.');
    }
  }
}
