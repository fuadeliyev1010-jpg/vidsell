import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/repositories/city_repository.dart';
import 'package:vidsell/features/discover/repositories/subcategory_repository.dart';

class ApiSubcategoryRepository implements SubcategoryRepository {
  ApiSubcategoryRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<String>> fetchCategories() async {
    final data = await _client.get('/products/categories');
    if (data is! List) {
      throw StateError('Invalid product categories response.');
    }
    return List.unmodifiable(
      data.map((category) {
        if (category is! String || category.trim().isEmpty) {
          throw StateError('Invalid product category value.');
        }
        return category.trim();
      }),
    );
  }

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
    final data = await _client.get('/products/cities');
    if (data is! List) {
      throw StateError('Invalid product cities response.');
    }
    return List.unmodifiable(
      data.map((city) {
        if (city is! String || city.trim().isEmpty) {
          throw StateError('Invalid product city value.');
        }
        final name = city.trim();
        return City(id: name, name: name);
      }),
    );
  }
}
