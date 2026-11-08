import '../../core/utils/currency_formatter.dart';
import '../enums/transaction_type.dart';

enum WalletTransactionStatus { pending, completed, failed }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.currency = fallbackCurrencyCode,
    this.status = WalletTransactionStatus.completed,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime? createdAt;
  final String currency;
  final WalletTransactionStatus status;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString().toUpperCase();
    return WalletTransaction(
      id: '${json['id'] ?? ''}',
      type:
          TransactionType.fromCode(json['type'] as String?) ??
          TransactionType.unknown,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      currency: json['currency'] as String? ?? fallbackCurrencyCode,
      status: switch (rawStatus) {
        'PENDING' => WalletTransactionStatus.pending,
        'FAILED' => WalletTransactionStatus.failed,
        'COMPLETED' || 'SUCCESS' || null => WalletTransactionStatus.completed,
        _ => WalletTransactionStatus.pending,
      },
    );
  }
}

class RefundRequest {
  const RefundRequest({required this.transactionId, required this.amount});

  final String transactionId;
  final double amount;
}
