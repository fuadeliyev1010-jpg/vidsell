import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/repositories/mock_search_repository.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';

void main() {
  test(
    'search results use the same listing feed as discover and map',
    () async {
      final homeRepository = MockHomeRepository();
      final searchRepository = MockSearchRepository(
        homeRepository: homeRepository,
      );

      final feed = await homeRepository.fetchListings(size: 50);
      final results = await searchRepository.search('Samsung');

      expect(feed.listings.map((listing) => listing.id), contains('listing-2'));
      expect(results.map((listing) => listing.id), ['listing-2']);
    },
  );
}
