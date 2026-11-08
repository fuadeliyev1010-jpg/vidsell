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
    var pageNumber = 1;
    var isLastPage = false;
    do {
      final page = await homeRepository.fetchListings(
        page: pageNumber,
        size: 50,
      );
      listings.addAll(
        page.items.map((item) => item.product).whereType<Product>(),
      );
      isLastPage = page.last;
      if (!isLastPage &&
          (page.page != pageNumber - 1 || pageNumber >= page.totalPages)) {
        throw StateError('Mock search pagination returned an invalid page.');
      }
      pageNumber++;
    } while (!isLastPage);

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
