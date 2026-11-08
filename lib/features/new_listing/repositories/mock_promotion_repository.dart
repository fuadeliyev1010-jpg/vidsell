import 'package:vidsell/models/promotion/promotion_availability.dart';
import 'package:vidsell/features/new_listing/repositories/promotion_repository.dart';

class MockPromotionRepository implements PromotionRepository {
  @override
  Future<PromotionAvailability> fetchAvailability() async =>
      const PromotionAvailability(
        freeDailyQuota: 3,
        prices: {'BOOST': 1, 'VIP': 5, 'PREMIUM': 10},
      );
}
