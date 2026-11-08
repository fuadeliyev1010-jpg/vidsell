// TODO(api): verify against openapi.json or a real response
class StoreStatistics {
  const StoreStatistics({
    this.views,
    this.listings,
    this.followers,
    this.responseRate,
    this.averageResponseTimeMinutes,
    this.callsReceived,
    this.messagesReceived,
  });

  final int? views;
  final int? listings;
  final int? followers;
  final double? responseRate;
  final int? averageResponseTimeMinutes;
  final int? callsReceived;
  final int? messagesReceived;

  factory StoreStatistics.fromJson(Map<String, dynamic> json) =>
      StoreStatistics(
        views: _intOrNull(json['views']),
        listings: _intOrNull(json['listings'] ?? json['products']),
        followers: _intOrNull(json['followers']),
        responseRate: _doubleOrNull(json['responseRate']),
        averageResponseTimeMinutes: _intOrNull(
          json['averageResponseTimeMinutes'] ?? json['averageResponseTime'],
        ),
        callsReceived: _intOrNull(json['callsReceived']),
        messagesReceived: _intOrNull(json['messagesReceived']),
      );

  static int? _intOrNull(Object? value) => value is num
      ? value.toInt()
      : value == null
      ? null
      : int.tryParse('$value');
  static double? _doubleOrNull(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value');
}
