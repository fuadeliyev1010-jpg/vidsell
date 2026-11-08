class StoreStatistics {
  const StoreStatistics({
    this.views,
    this.calls,
    this.messages,
    this.listings,
    this.followers,
    this.range,
    this.series = const [],
  });

  final int? views;
  final int? calls;
  final int? messages;
  final int? listings;
  final int? followers;
  final String? range;
  final List<DailyPoint> series;

  factory StoreStatistics.fromJson(Map<String, dynamic> json) =>
      StoreStatistics(
        views: _intOrNull(json['views']),
        calls: _intOrNull(json['calls']),
        messages: _intOrNull(json['messages']),
        listings: _intOrNull(json['listings']),
        followers: _intOrNull(json['followers']),
        range: json['range'] as String?,
        series: json['series'] is List
            ? (json['series'] as List)
                  .whereType<Map>()
                  .map(
                    (item) =>
                        DailyPoint.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList(growable: false)
            : const [],
      );

  static int? _intOrNull(Object? value) => value is num
      ? value.toInt()
      : value == null
      ? null
      : int.tryParse('$value');
}

class DailyPoint {
  const DailyPoint({this.date, this.calls, this.messages});

  final DateTime? date;
  final int? calls;
  final int? messages;

  factory DailyPoint.fromJson(Map<String, dynamic> json) => DailyPoint(
    date: DateTime.tryParse('${json['date'] ?? ''}'),
    calls: StoreStatistics._intOrNull(json['calls']),
    messages: StoreStatistics._intOrNull(json['messages']),
  );
}
