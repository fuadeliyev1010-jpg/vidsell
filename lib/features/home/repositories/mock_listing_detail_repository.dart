import 'package:vidsell/features/home/repositories/home_repository.dart';
import 'package:vidsell/features/home/repositories/listing_detail_repository.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';
import 'package:vidsell/models/product/product.dart';

class MockListingDetailRepository implements ListingDetailRepository {
  MockListingDetailRepository({HomeRepository? homeRepository})
    : _homeRepository = homeRepository ?? MockHomeRepository();

  final HomeRepository _homeRepository;

  @override
  Future<Product> fetchListing(String listingId) async {
    final page = await _homeRepository.fetchListings(size: 50);
    for (final item in page.items) {
      final listing = item.product;
      if (listing?.id == listingId) {
        return listing!;
      }
    }

    return Product(
      id: listingId,
      title: 'Demo listing',
      description: 'Demo listing used while the API is unavailable.',
      price: 100,
      currency: 'AZN',
      city: 'İstanbul',
      cityId: 'istanbul',
      categoryId: 'electronics',
      subcategoryId: 'phones',
      sellerId: 'mock-user-1',
      sellerName: 'Vidsell seller',
      imageUrls: const [],
      createdAt: DateTime.utc(2025),
    );
  }
}
