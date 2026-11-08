import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/repositories/city_repository.dart';
import 'package:vidsell/features/discover/repositories/subcategory_repository.dart';

class ApiSubcategoryRepository implements SubcategoryRepository {
  ApiSubcategoryRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Subcategory>> fetchForCategory(String categoryId) async {
    final category = switch (categoryId) {
      'electronics' => 'ELECTRONICS',
      'vehicles' || 'transport' => 'TRANSPORT',
      'real-estate' => 'REAL_ESTATE',
      'home-appliances' => 'HOME_APPLIANCES',
      'special-occasion-clothing' => 'SPECIAL_OCCASION',
      'cosmetics' => 'COSMETICS',
      _ => throw StateError('Unsupported product category.'),
    };
    final data = await _client.get(
      '/products/subcategories',
      queryParameters: {'category': category},
    );
    final enumData = await _client.get('/i18n/enums');
    return Subcategory.fromApiResponse(data, enumData, categoryId: categoryId);
  }
}

class ApiCityRepository implements CityRepository {
  ApiCityRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<City>> fetchCities() async {
    final data = await _client.get('/cities');
    return parsePage(data, (json) => json).items
        .map(
          (json) => City(
            id: json['id'].toString(),
            name: json['name'] as String? ?? '',
          ),
        )
        .toList(growable: false);
  }
}
