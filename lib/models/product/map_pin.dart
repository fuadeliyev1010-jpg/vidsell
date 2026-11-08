class MapPin {
  const MapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.distanceLabel,
  });

  final String id;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final String? distanceLabel;

  factory MapPin.fromJson(Map<String, dynamic> json) => MapPin(
    id: '${json['id'] ?? ''}',
    latitude: _double(json['latitude']),
    longitude: _double(json['longitude']),
    distanceKm: _doubleOrNull(json['distanceKm']),
    distanceLabel: json['distanceLabel'] as String?,
  );

  static double _double(Object? value) => _doubleOrNull(value) ?? 0;
  static double? _doubleOrNull(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value');
}
