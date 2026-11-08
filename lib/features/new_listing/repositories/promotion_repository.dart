import 'package:vidsell/models/promotion/promotion_availability.dart';

abstract interface class PromotionRepository {
  Future<PromotionAvailability> fetchAvailability();
}
