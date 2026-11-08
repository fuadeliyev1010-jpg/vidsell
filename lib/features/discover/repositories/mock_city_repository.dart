import 'package:vidsell/features/discover/models/city.dart';
import 'package:vidsell/features/discover/repositories/city_repository.dart';

class MockCityRepository implements CityRepository {
  static const _cities = [
    City(id: 'istanbul', name: 'İstanbul'),
    City(id: 'baku', name: 'Bakı'),
    City(id: 'ankara', name: 'Ankara'),
    City(id: 'ganja', name: 'Gəncə'),
    City(id: 'izmir', name: 'İzmir'),
    City(id: 'antalya', name: 'Antalya'),
    City(id: 'bursa', name: 'Bursa'),
    City(id: 'konya', name: 'Konya'),
    City(id: 'trabzon', name: 'Trabzon'),
    City(id: 'adana', name: 'Adana'),
    City(id: 'samsun', name: 'Samsun'),
    City(id: 'gaziantep', name: 'Gaziantep'),
    City(id: 'eskisehir', name: 'Eskişehir'),
  ];

  @override
  Future<List<City>> fetchCities() async => _cities;

  List<City> fetchCitiesSync() => _cities;
}
