import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/network/page_response_parser.dart';
import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/models/enums/payment_method.dart';
import 'package:vidsell/models/enums/transaction_type.dart';
import 'package:vidsell/models/wallet/top_up_intent.dart';
import 'package:vidsell/models/wallet/top_up_request.dart';
import 'package:vidsell/models/wallet/wallet_balance.dart';
import 'package:vidsell/models/wallet/wallet_transaction.dart';

class ApiWalletRepository implements WalletRepository {
  ApiWalletRepository(this._client);

  final ApiClient _client;

  @override
  Future<WalletBalance> fetchWallet() async {
    final data = await _client.get('/wallet/balance');
    if (data is! Map<String, dynamic> ||
        data['balance'] is! num ||
        data['currency'] is! String) {
      throw StateError('Invalid wallet balance response.');
    }
    return WalletBalance(
      balance: (data['balance'] as num).toDouble(),
      currency: data['currency'] as String,
      updatedAt: data['updatedAt'] is String
          ? DateTime.tryParse(data['updatedAt'] as String)
          : null,
    );
  }

  @override
  Future<List<WalletTransaction>> fetchTransactions() async {
    final data = await _client.get(
      '/wallet/transactions',
      queryParameters: {'page': 1, 'size': 20},
    );
    return parsePage(data, _transaction).items;
  }

  @override
  Future<List<PaymentMethodOption>> fetchPaymentMethods() async {
    final data = await _client.get('/i18n/enums');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid enum localization response.');
    }
    return PaymentMethod.optionsFromI18nResponse(data);
  }

  @override
  Future<WalletTransaction> topUp({
    required double amount,
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) async =>
      throw UnsupportedError('Raw card details are not supported by the API.');

  @override
  Future<WalletTransaction> topUpWithPaymentToken({
    required double amount,
    required String paymentToken,
  }) async => throw UnsupportedError(
    'Payment tokens are not accepted by the documented wallet API.',
  );

  @override
  Future<TopUpIntent> createTopUpIntent({required TopUpRequest request}) async {
    final data = await _client.post('/wallet/top-up', data: request.toJson());
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid top-up intent response.');
    }
    return TopUpIntent.fromJson(data);
  }

  @override
  Future<TopUpIntent> fetchTopUpIntent(String id) async {
    final data = await _client.get('/wallet/top-up/$id');
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid top-up intent response.');
    }
    return TopUpIntent.fromJson(data);
  }

  @override
  Future<TopUpIntent> confirmTopUp(String id) async {
    final data = await _client.post('/wallet/top-up/$id/confirm');
    if (data is Map<String, dynamic>) return TopUpIntent.fromJson(data);
    if (data != null && data != '') {
      throw StateError('Invalid top-up confirmation response.');
    }
    return fetchTopUpIntent(id);
  }

  @override
  Future<WalletTransaction> refund(RefundRequest request) async =>
      throw UnsupportedError('Wallet refunds are not supported by the API.');

  WalletTransaction _transaction(Map<String, dynamic> data) {
    final id = data['id']?.toString();
    final amount = data['amount'];
    final createdAt = data['createdAt'];
    if (id == null || amount is! num || createdAt is! String) {
      throw StateError('Invalid wallet transaction response.');
    }
    return WalletTransaction(
      id: id,
      amount: amount.toDouble(),
      currency: data['currency'] as String? ?? 'TRY',
      type:
          TransactionType.fromCode(data['type'] as String?) ??
          TransactionType.unknown,
      description: data['description'] as String? ?? '',
      status: _status(data['status']),
      createdAt: DateTime.tryParse(createdAt),
    );
  }

  static WalletTransactionStatus _status(dynamic value) {
    switch ('$value'.toUpperCase()) {
      case 'PENDING':
        return WalletTransactionStatus.pending;
      case 'FAILED':
        return WalletTransactionStatus.failed;
      case 'COMPLETED':
      case 'SUCCESS':
      case 'null':
        return WalletTransactionStatus.completed;
      default:
        return WalletTransactionStatus.pending;
    }
  }
}
