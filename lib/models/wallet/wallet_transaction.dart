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
}

class RefundRequest {
  const RefundRequest({required this.transactionId, required this.amount});

  final String transactionId;
  final double amount;
}
