import 'package:vidsell/features/discover/models/search_suggestion.dart';
import 'package:vidsell/models/product/product.dart';

abstract interface class SearchRepository {
  Future<List<Product>> search(String query);
  Future<List<SearchSuggestion>> suggestions(String query);
}
