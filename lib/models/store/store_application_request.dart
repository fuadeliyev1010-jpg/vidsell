class StoreApplicationRequest {
  const StoreApplicationRequest({
    required this.name,
    required this.category,
    this.logoUrl,
    this.open24Hours,
    this.workingHours = const [],
  });

  final String name;
  final String category;
  final String? logoUrl;
  final bool? open24Hours;
  final List<StoreWorkingHour> workingHours;

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    if (logoUrl != null) 'logoUrl': logoUrl,
    if (open24Hours != null) 'open24Hours': open24Hours,
    if (workingHours.isNotEmpty)
      'workingHours': workingHours.map((hour) => hour.toJson()).toList(),
  };

  factory StoreApplicationRequest.fromJson(Map<String, dynamic> json) =>
      StoreApplicationRequest(
        name: '${json['name'] ?? ''}',
        category: '${json['category'] ?? ''}',
        logoUrl: json['logoUrl'] as String?,
        open24Hours: json['open24Hours'] as bool?,
        workingHours: json['workingHours'] is List
            ? (json['workingHours'] as List)
                  .whereType<Map>()
                  .map(
                    (hour) => StoreWorkingHour.fromJson(
                      Map<String, dynamic>.from(hour),
                    ),
                  )
                  .toList(growable: false)
            : const [],
      );
}

class StoreWorkingHour {
  const StoreWorkingHour({
    required this.day,
    required this.opens,
    required this.closes,
  });

  final String day;
  final String opens;
  final String closes;

  Map<String, dynamic> toJson() => {
    'day': day,
    'opens': opens,
    'closes': closes,
  };

  factory StoreWorkingHour.fromJson(Map<String, dynamic> json) =>
      StoreWorkingHour(
        day: '${json['day'] ?? ''}',
        opens: '${json['opens'] ?? ''}',
        closes: '${json['closes'] ?? ''}',
      );
}
