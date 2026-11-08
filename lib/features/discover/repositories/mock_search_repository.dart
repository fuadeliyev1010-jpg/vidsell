import 'package:vidsell/features/discover/models/search_suggestion.dart';
import 'package:vidsell/features/discover/repositories/search_repository.dart';
import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/models/product/product.dart';

class MockSearchRepository implements SearchRepository {
  MockSearchRepository({required this.homeRepository});

  final HomeRepository homeRepository;

  @override
  Future<List<Product>> search(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const [];
    final listings = <Product>[];
    String? cursor;
    do {
      final page = await homeRepository.fetchListings(
        cursor: cursor,
        limit: 50,
      );
      listings.addAll(
        page.items.map((item) => item.product).whereType<Product>(),
      );
      if (page.nextCursor == cursor && page.nextCursor != null) {
        throw StateError('Mock listings feed returned a repeated cursor.');
      }
      cursor = page.nextCursor;
    } while (cursor != null);

    return listings
        .where(
          (item) =>
              item.title.toLowerCase().contains(normalizedQuery) ||
              item.description.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  @override
  Future<List<SearchSuggestion>> suggestions(String query) async {
    if (query.trim().isEmpty) return const [];
    return [
      SearchSuggestion(title: query, subtitle: '', isAllCategories: true),
    ];
  }
}
