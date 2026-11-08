import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/models/wallet/top_up_intent.dart';
import 'package:vidsell/models/wallet/wallet_balance.dart';
import 'package:vidsell/models/wallet/wallet_transaction.dart';
import 'package:vidsell/models/enums/transaction_type.dart';

class ApiWalletRepository implements WalletRepository {
  ApiWalletRepository(this._client);

  final ApiClient _client;

  @override
  Future<WalletBalance> fetchWallet() async {
    final data = await _client.get('/wallet');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid wallet response.');
    }
    return WalletBalance(
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'AZN',
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  @override
  Future<List<WalletTransaction>> fetchTransactions() async {
    final data = await _client.get('/wallet/transactions');
    return parsePage(data, _transaction).items;
  }

  @override
  Future<WalletTransaction> topUp({
    required double amount,
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) async => throw StateError(
    'Use PaymentProvider.tokenizeCard before topUpWithPaymentToken.',
  );

  @override
  Future<WalletTransaction> topUpWithPaymentToken({
    required double amount,
    required String paymentToken,
  }) async {
    final data = await _client.post(
      '/wallet/top-ups',
      data: {'amount': amount, 'paymentToken': paymentToken},
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid top-up response.');
    }

    return _transaction(data);
  }

  @override
  Future<TopUpIntent> createTopUpIntent({
    required double amount,
    required String paymentToken,
  }) async {
    final data = await _client.post(
      '/wallet/top-ups',
      data: {'amount': amount, 'paymentToken': paymentToken},
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid top-up intent response.');
    }
    return TopUpIntent.fromJson(data);
  }

  @override
  Future<WalletTransaction> refund(RefundRequest request) async {
    final data = await _client.post(
      '/wallet/refunds',
      data: {'transactionId': request.transactionId, 'amount': request.amount},
    );
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid refund response.');
    }
    return _transaction(data);
  }

  WalletTransaction _transaction(Map<String, dynamic> data) =>
      WalletTransaction(
        id: data['id'].toString(),
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
        currency: data['currency'] as String? ?? 'AZN',
        type:
            TransactionType.fromCode(data['type'] as String?) ??
            TransactionType.topUp,
        description: data['description'] as String? ?? '',
        status: _status(data['status']),
        createdAt: DateTime.parse(data['createdAt'] as String),
      );

  static WalletTransactionStatus _status(dynamic value) {
    switch ('$value'.toUpperCase()) {
      case 'COMPLETED':
        return WalletTransactionStatus.completed;
      case 'FAILED':
        return WalletTransactionStatus.failed;
      default:
        return WalletTransactionStatus.pending;
    }
  }
}
