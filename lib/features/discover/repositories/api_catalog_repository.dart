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
    final data = await _client.get(
      '/subcategories',
      queryParameters: {'categoryId': categoryId},
    );
    return parsePage(data, (json) => json).items
        .map(
          (json) => Subcategory(
            id: json['id'].toString(),
            label: json['name'] as String? ?? '',
            categoryId: json['categoryId']?.toString() ?? categoryId,
          ),
        )
        .toList(growable: false);
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
