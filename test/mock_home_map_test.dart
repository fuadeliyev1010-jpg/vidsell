import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/home/repositories/mock_home_repository.dart';

void main() {
  test('mock listings include coordinates for map markers', () async {
    final page = await MockHomeRepository().fetchListings(limit: 50);

    expect(page.listings, isNotEmpty);
    expect(
      page.listings.every(
        (listing) => listing.latitude != null && listing.longitude != null,
      ),
      isTrue,
    );
  });
}
