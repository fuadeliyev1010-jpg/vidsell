class TopUpIntent {
  const TopUpIntent({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.invoiceNumber,
  });

  final String id;
  final double amount;
  final String method;
  final String status;
  final String invoiceNumber;

  factory TopUpIntent.fromJson(Map<String, dynamic> json) {
    return TopUpIntent(
      id: json['id'].toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      invoiceNumber:
          (json['invoiceNumber'] ?? json['invoice_number'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'method': method,
    'status': status,
    'invoiceNumber': invoiceNumber,
  };
}
