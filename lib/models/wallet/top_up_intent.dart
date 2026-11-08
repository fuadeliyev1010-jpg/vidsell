class TopUpIntent {
  const TopUpIntent({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.invoiceNumber,
    this.currency = 'TRY',
    this.methodLabel,
    this.statusLabel,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final double amount;
  final String method;
  final String status;
  final String invoiceNumber;
  final String currency;
  final String? methodLabel;
  final String? statusLabel;
  final DateTime? createdAt;
  final DateTime? completedAt;

  factory TopUpIntent.fromJson(Map<String, dynamic> json) {
    return TopUpIntent(
      id: json['id'].toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      invoiceNumber:
          (json['invoiceNo'] ?? json['invoiceNumber'] ?? json['invoice_number'])
              ?.toString() ??
          '',
      currency: json['currency'] as String? ?? 'TRY',
      methodLabel: json['methodLabel'] as String?,
      statusLabel: json['statusLabel'] as String?,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      completedAt: DateTime.tryParse('${json['completedAt'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'method': method,
    'status': status,
    'invoiceNo': invoiceNumber,
    'currency': currency,
    if (methodLabel != null) 'methodLabel': methodLabel,
    if (statusLabel != null) 'statusLabel': statusLabel,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
  };
}
