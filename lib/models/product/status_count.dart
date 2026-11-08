import '../enums/product_status.dart';

class StatusCount {
  const StatusCount({required this.status, required this.count});

  final ProductStatus status;
  final int count;

  factory StatusCount.fromJson(Map<String, dynamic> json) => StatusCount(
    status:
        ProductStatus.fromCode(
          (json['status'] ?? json['productStatus'])?.toString().toUpperCase(),
        ) ??
        ProductStatus.active,
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}
