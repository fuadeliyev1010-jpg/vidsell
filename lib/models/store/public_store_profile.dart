import '../../core/network/media_url.dart';

class PublicStoreProfile {
  const PublicStoreProfile({
    required this.sellerId,
    this.fullName,
    this.avatarUrl,
    this.storeName,
    this.category,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.open24Hours,
    this.workingHours = const [],
    this.isOpen,
    this.opensAt,
    this.closesAt,
    this.products,
    this.views,
    this.followers,
  });

  final String sellerId;
  final String? fullName;
  final String? avatarUrl;
  final String? storeName;
  final String? category;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final bool? open24Hours;
  final List<Map<String, dynamic>> workingHours;
  final bool? isOpen;
  final String? opensAt;
  final String? closesAt;
  final int? products;
  final int? views;
  final int? followers;

  // TODO(api): seller phone not in ProductResponse/StoreProfileResponse.
  factory PublicStoreProfile.fromJson(
    Map<String, dynamic> json, {
    String? mediaOrigin,
  }) {
    final profile = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final store = profile['store'] is Map
        ? Map<String, dynamic>.from(profile['store'] as Map)
        : const <String, dynamic>{};
    final stats = profile['stats'] is Map
        ? Map<String, dynamic>.from(profile['stats'] as Map)
        : const <String, dynamic>{};
    final hours = store['workingHours'];
    return PublicStoreProfile(
      sellerId: '${profile['id'] ?? ''}',
      fullName: _nonEmpty(profile['fullName']),
      avatarUrl: _resolve(profile['avatarUrl'] as String?, mediaOrigin),
      storeName: _nonEmpty(store['name']),
      category: _nonEmpty(store['category']),
      description: _nonEmpty(store['description']),
      logoUrl: _resolve(store['logoUrl'] as String?, mediaOrigin),
      bannerUrl: _resolve(store['bannerUrl'] as String?, mediaOrigin),
      open24Hours: store['open24Hours'] as bool?,
      workingHours: hours is List
          ? hours
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(growable: false)
          : const [],
      isOpen: store['open'] as bool?,
      opensAt: _nonEmpty(store['opensAt']),
      closesAt: _nonEmpty(store['closesAt']),
      products: _intOrNull(stats['products']),
      views: _intOrNull(stats['views']),
      followers: _intOrNull(stats['followers']),
    );
  }

  static String? _resolve(String? value, String? origin) {
    if (origin == null) return _nonEmpty(value);
    return resolveMediaUrl(value, origin: origin);
  }

  static String? _nonEmpty(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intOrNull(Object? value) => value is num
      ? value.toInt()
      : value == null
      ? null
      : int.tryParse('$value');
}
