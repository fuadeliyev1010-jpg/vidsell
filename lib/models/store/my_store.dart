import 'store_stats.dart';
import '../enums/store_status.dart';

class MyStore {
  const MyStore({
    this.id = '',
    required this.name,
    required this.category,
    required this.description,
    required this.phone,
    required this.workingHours,
    required this.status,
    required this.isOpen,
    this.logoUrl,
    this.rejectionReason,
    this.reviewedAt,
    this.createdAt,
    this.stats,
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
  final bool isOpen;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final StoreStats? stats;
  final String? openUntil;

  StoreStatus get statusValue => StoreStatus.fromCode(status);

  factory MyStore.fromJson(Map<String, dynamic> json) => MyStore(
    id: '${json['id'] ?? json['sellerId'] ?? json['storeId'] ?? ''}',
    name: '${json['name'] ?? json['storeName'] ?? ''}',
    category: '${json['category'] ?? json['categoryName'] ?? ''}',
    logoUrl: json['logoUrl'] as String? ?? json['logoPath'] as String?,
    description: '${json['description'] ?? ''}',
    phone: '${json['phone'] ?? json['phoneNumber'] ?? ''}',
    workingHours: '${json['workingHours'] ?? ''}',
    status: '${json['status'] ?? ''}',
    isOpen: (json['open'] ?? json['isOpen']) as bool? ?? false,
    rejectionReason: json['rejectionReason'] as String?,
    reviewedAt: DateTime.tryParse('${json['reviewedAt'] ?? ''}'),
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    stats: json['stats'] is Map
        ? StoreStats.fromJson(Map<String, dynamic>.from(json['stats'] as Map))
        : null,
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
    'isOpen': isOpen,
    if (rejectionReason != null) 'rejectionReason': rejectionReason,
    if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (stats != null) 'stats': stats!.toJson(),
    if (openUntil != null) 'openUntil': openUntil,
  };
}

extension MyStoreUi on MyStore {
  String get displayName => name.trim();
  String get categoryDisplay => category.trim();
  String get phoneDisplay => phone.trim();
  String get workingHoursDisplay => workingHours.trim();
  String get statusDisplay => status.trim().toUpperCase();
}
