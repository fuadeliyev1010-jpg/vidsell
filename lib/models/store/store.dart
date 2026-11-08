import 'store_stats.dart';
import '../enums/store_status.dart';

class Store {
  const Store({
    required this.id,
    required this.name,
    this.category = '',
    this.logoUrl,
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

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: '${json['id'] ?? json['sellerId'] ?? json['storeId'] ?? ''}',
    name: '${json['name'] ?? json['storeName'] ?? json['fullName'] ?? ''}',
    category: '${json['category'] ?? json['categoryName'] ?? ''}',
    logoUrl:
        json['logoUrl'] as String? ??
        json['avatarUrl'] as String? ??
        json['logoPath'] as String?,
    description: '${json['description'] ?? ''}',
    phone: '${json['phone'] ?? json['phoneNumber'] ?? ''}',
    workingHours: '${json['workingHours'] ?? ''}',
    status: '${json['status'] ?? ''}',
    rejectionReason: json['rejectionReason'] as String?,
    reviewedAt: DateTime.tryParse('${json['reviewedAt'] ?? ''}'),
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    stats: json['stats'] is Map
        ? StoreStats.fromJson(Map<String, dynamic>.from(json['stats'] as Map))
        : null,
    isOpen: (json['open'] ?? json['isOpen']) as bool?,
    openUntil: json['openUntil']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    if (logoUrl != null) 'logoUrl': logoUrl,
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
