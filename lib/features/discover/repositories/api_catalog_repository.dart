import 'package:flutter/foundation.dart';
import 'package:vidsell/core/network/api_exception.dart';
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
    dynamic subcategoryData;
    dynamic enumData;
    var loadingSubcategories = true;
    try {
      subcategoryData = await _client.get('/products/subcategories');
      loadingSubcategories = false;
      enumData = await _client.getEnumCatalog();
      return Subcategory.fromApiResponse(
        subcategoryData,
        enumData,
        categoryId: categoryId,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        final rawSubcategories =
            subcategoryData ??
            (loadingSubcategories && error is ApiException
                ? error.rawResponseBody
                : null);
        final rawEnums =
            enumData ??
            (!loadingSubcategories && error is ApiException
                ? error.rawResponseBody
                : null);
        debugPrint(
          '[Subcategory] Load failed: $error\n'
          '$stackTrace\n'
          'GET /products/subcategories body: $rawSubcategories\n'
          'GET /i18n/enums body: $rawEnums',
        );
      }
      rethrow;
    }
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
