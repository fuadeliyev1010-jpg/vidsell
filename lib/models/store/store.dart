import '../../core/network/media_url.dart';
import 'store_stats.dart';
import '../enums/store_status.dart';

class Store {
  const Store({
    required this.id,
    required this.name,
    this.category = '',
    this.logoUrl,
    this.bannerUrl,
    this.description = '',
    this.phone = '',
    this.workingHours = '',
    this.status = '',
    this.rejectionReason,
    this.reviewedAt,
    this.createdAt,
    this.stats,
    this.isOpen,
    this.openUntil,
  });

  final String id;
  final String name;
  final String category;
  final String? logoUrl;
  final String? bannerUrl;
  final String description;
  final String phone;
  final String workingHours;
  final String status;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final StoreStats? stats;
  final bool? isOpen;
  final String? openUntil;

  String get fullName => name;
  String? get avatarUrl => logoUrl;
  StoreStatus get statusValue => StoreStatus.fromCode(status);

  factory Store.fromJson(Map<String, dynamic> json, {String? mediaOrigin}) {
    final nestedStore = json['store'] is Map
        ? Map<String, dynamic>.from(json['store'] as Map)
        : const <String, dynamic>{};
    final values = {...nestedStore, ...json};
    return Store(
      id: '${values['id'] ?? values['sellerId'] ?? values['storeId'] ?? ''}',
      name:
          '${values['name'] ?? values['storeName'] ?? values['fullName'] ?? ''}',
      category: '${values['category'] ?? values['categoryName'] ?? ''}',
      logoUrl: _resolveMedia(
        values['logoUrl'] as String? ??
            values['avatarUrl'] as String? ??
            values['logoPath'] as String?,
        mediaOrigin,
      ),
      bannerUrl: _resolveMedia(values['bannerUrl'] as String?, mediaOrigin),
      description: '${values['description'] ?? ''}',
      phone: '${values['phone'] ?? values['phoneNumber'] ?? ''}',
      workingHours: '${values['workingHours'] ?? ''}',
      status: '${values['status'] ?? ''}',
      rejectionReason: values['rejectionReason'] as String?,
      reviewedAt: DateTime.tryParse('${values['reviewedAt'] ?? ''}'),
      createdAt: DateTime.tryParse('${values['createdAt'] ?? ''}'),
      stats: values['stats'] is Map
          ? StoreStats.fromJson(
              Map<String, dynamic>.from(values['stats'] as Map),
            )
          : null,
      isOpen: (values['open'] ?? values['isOpen']) as bool?,
      openUntil: values['openUntil']?.toString(),
    );
  }

  static String? _resolveMedia(String? value, String? origin) =>
      origin == null ? value : resolveMediaUrl(value, origin: origin);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    if (logoUrl != null) 'logoUrl': logoUrl,
    if (bannerUrl != null) 'bannerUrl': bannerUrl,
    'description': description,
    'phone': phone,
    'workingHours': workingHours,
    'status': status,
    if (rejectionReason != null) 'rejectionReason': rejectionReason,
    if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (stats != null) 'stats': stats!.toJson(),
    if (isOpen != null) 'isOpen': isOpen,
    if (openUntil != null) 'openUntil': openUntil,
  };
}

extension StoreUi on Store {
  String get displayName => name.trim();
  String get categoryDisplay => category.trim();
  String get phoneDisplay => phone.trim();
  String get workingHoursDisplay => workingHours.trim();
  String get statusDisplay => status.trim().toUpperCase();
}
