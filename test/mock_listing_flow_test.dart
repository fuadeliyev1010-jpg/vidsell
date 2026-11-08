import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/cabinet/repositories/mock_user_listing_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_search_repository.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';
import 'package:vidsell/features/home/repositories/mock_listing_detail_repository.dart';
import 'package:vidsell/features/new_listing/models/listing_draft.dart';
import 'package:vidsell/features/new_listing/repositories/mock_listing_repository.dart';
import 'package:vidsell/models/enums/product_status.dart';

void main() {
  test(
    'created listing flows through owner, discover, search, detail and delete',
    () async {
      final ownerListings = MockUserListingRepository();
      final homeRepository = MockHomeRepository(
        userListingRepository: ownerListings,
      );
      final listingRepository = MockListingRepository(
        onListingCreated: ownerListings.addListing,
      );
      final searchRepository = MockSearchRepository(
        homeRepository: homeRepository,
      );
      final detailRepository = MockListingDetailRepository(
        homeRepository: homeRepository,
      );

      final created = await listingRepository.createListing(
        const ListingDraft(
          categoryId: 'electronics',
          categoryName: 'Electronics',
          subcategoryId: 'phones',
          subcategoryName: 'Phones',
          brand: 'Brand',
          model: 'Phone model',
          price: 250,
          city: 'Baku',
          cityId: 'baku',
          condition: ListingCondition.used,
          delivery: DeliveryOption.free,
          title: 'Test phone',
          description: 'A searchable phone',
          sellerName: 'Contact',
          email: 'contact@example.test',
          phone: '+994000000000',
          contactMethod: 'callsOnly',
          imagePaths: ['https://cdn.example.test/photo.jpg'],
          videoPaths: [],
        ),
      );

      final pending = await ownerListings.fetchMyListings();
      expect(pending.single.id, created.id);
      expect(pending.single.status, ProductStatus.underReview);

      await ownerListings.updateListingStatus(created.id, ProductStatus.active);
      final discovered = await homeRepository.fetchListings(limit: 50);
      final visibleListing = discovered.listings.singleWhere(
        (listing) => listing.id == created.id,
      );
      expect(visibleListing.categoryId, 'electronics');
      expect(visibleListing.subcategoryId, 'phones');
      expect(visibleListing.cityId, 'baku');
      expect(
        (await searchRepository.search('searchable')).single.id,
        created.id,
      );

      final detail = await detailRepository.fetchListing(created.id);
      expect(detail.id, created.id);
      expect(detail.status, ProductStatus.active);
      expect(detail.sellerId, 'mock-user');

      await ownerListings.deleteListing(created.id);
      expect(await ownerListings.fetchMyListings(), isEmpty);
      expect(
        (await homeRepository.fetchListings(
          limit: 50,
        )).listings.any((listing) => listing.id == created.id),
        isFalse,
      );
    },
  );
}
