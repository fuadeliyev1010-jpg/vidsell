import 'package:vidsell/features/discover/models/city.dart';

abstract interface class CityRepository {
  Future<List<City>> fetchCities();
}
