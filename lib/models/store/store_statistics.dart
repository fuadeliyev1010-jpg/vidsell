class StoreStatistics {
  const StoreStatistics({this.views, this.listings, this.followers});

  final int? views;
  final int? listings;
  final int? followers;

  factory StoreStatistics.fromJson(Map<String, dynamic> json) =>
      StoreStatistics(
        views: _intOrNull(json['views']),
        listings: _intOrNull(json['listings']),
        followers: _intOrNull(json['followers']),
      );

  static int? _intOrNull(Object? value) => value is num
      ? value.toInt()
      : value == null
      ? null
      : int.tryParse('$value');
}
