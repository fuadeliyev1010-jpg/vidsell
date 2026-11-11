import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/discover/models/search_suggestion.dart';
import 'package:vidsell/features/discover/repositories/search_repository.dart';
import 'package:vidsell/models/product/product.dart';

class ApiSearchRepository implements SearchRepository {
  ApiSearchRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Product>> search(String query) async {
    final data = await _client.get('/search', queryParameters: {'q': query});
    return parsePage(data, Product.fromJson).items.toList(growable: false);
  }

  @override
  Future<List<SearchSuggestion>> suggestions(String query) async {
    final data = await _client.get(
      '/search/autocomplete',
      queryParameters: {'q': query},
    );
    if (data is! Map<String, dynamic> || data['suggestions'] is! List) {
      throw StateError('Invalid search autocomplete response.');
    }
    return (data['suggestions'] as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (item) => SearchSuggestion(
            title: item['title'] as String? ?? '',
            subtitle: [
              item['brand'] as String?,
              item['city'] as String?,
            ].whereType<String>().where((value) => value.isNotEmpty).join(', '),
          ),
        )
        .toList(growable: false);
  }
}
