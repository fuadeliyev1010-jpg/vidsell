import 'package:vidsell/models/promotion/promotion_availability.dart';
import 'package:vidsell/models/product/promote_request.dart';

abstract interface class PromotionRepository {
  Future<PromotionAvailability> fetchAvailability();

  Future<void> promoteProduct({
    required String productId,
    required PromoteRequest request,
  });
}
