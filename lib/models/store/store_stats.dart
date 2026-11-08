class StoreStats {
  const StoreStats({
    required this.products,
    required this.views,
    required this.followers,
  });

  final int products;
  final int views;
  final int followers;

  factory StoreStats.fromJson(Map<String, dynamic> json) => StoreStats(
    products: _int(json['products'] ?? json['productCount']),
    views: _int(json['views'] ?? json['viewCount']),
    followers: _int(json['followers'] ?? json['followerCount']),
  );

  Map<String, dynamic> toJson() => {
    'products': products,
    'views': views,
    'followers': followers,
  };

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
