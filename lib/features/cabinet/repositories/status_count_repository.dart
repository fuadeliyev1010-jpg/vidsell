import 'package:vidsell/models/product/status_count.dart';

abstract interface class StatusCountRepository {
  Future<List<StatusCount>> fetchStatusCounts();
}
