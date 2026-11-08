import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/models/enums/product_status.dart';
import 'package:vidsell/models/product/status_count.dart';

class MockStatusCountRepository implements StatusCountRepository {
  @override
  Future<List<StatusCount>> fetchStatusCounts() async => ProductStatus.values
      .map((status) => StatusCount(status: status, count: 0))
      .toList(growable: false);
}
