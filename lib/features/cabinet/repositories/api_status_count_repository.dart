import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/models/product/status_count.dart';

class ApiStatusCountRepository implements StatusCountRepository {
  ApiStatusCountRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<StatusCount>> fetchStatusCounts() async {
    final data = await _client.get('/products/me/status-counts');
    return parsePage(data, StatusCount.fromJson).items;
  }
}
