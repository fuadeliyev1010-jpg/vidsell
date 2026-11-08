import 'package:vidsell/features/cabinet/repositories/wallet_repository.dart';
import 'package:vidsell/models/wallet/top_up_intent.dart';
import 'package:vidsell/models/wallet/top_up_request.dart';
import 'package:vidsell/models/enums/payment_method.dart';
import 'package:vidsell/models/wallet/wallet_balance.dart';
import 'package:vidsell/models/wallet/wallet_transaction.dart';
import 'package:vidsell/models/enums/transaction_type.dart';

class MockWalletRepository implements WalletRepository {
  MockWalletRepository._();

  static final instance = MockWalletRepository._();

  double _balance = 0.70;
  final List<WalletTransaction> _transactions = [];
  final Map<String, TopUpIntent> _topUpIntents = {};

  @override
  Future<WalletBalance> fetchWallet() async {
    return WalletBalance(
      balance: _balance,
      currency: 'AZN',
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<WalletTransaction>> fetchTransactions() async {
    return List.unmodifiable(_transactions);
  }

  @override
  Future<List<PaymentMethodOption>> fetchPaymentMethods() async =>
      throw UnsupportedError(
        'Mock top-up uses the local card form, not API payment methods.',
      );

  @override
  Future<WalletTransaction> topUp({
    required double amount,
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) async {
    if (amount < 1 || amount > 5000) {
      throw ArgumentError('Məbləğ 1 və 5000 AZN arasında olmalıdır');
    }
    if (cardholderName.trim().length < 3) {
      throw ArgumentError('Kart sahibinin adı düzgün deyil');
    }
    if (cardNumber.length != 16) {
      throw ArgumentError('Kart nömrəsi 16 rəqəm olmalıdır');
    }
    if (expiryMonth < 1 || expiryMonth > 12) {
      throw ArgumentError('Kartın ayı düzgün deyil');
    }
    if (expiryYear < 0 || expiryYear > 99) {
      throw ArgumentError('Kartın ili düzgün deyil');
    }
    if (cvv.length != 3) {
      throw ArgumentError('CVV 3 rəqəm olmalıdır');
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    final transaction = WalletTransaction(
      id: 'wallet-tx-${_transactions.length + 1}',
      amount: amount,
      currency: 'AZN',
      type: TransactionType.topUp,
      status: WalletTransactionStatus.completed,
      description: 'Wallet top up',
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, transaction);
    _balance += amount;
    return transaction;
  }

  @override
  Future<WalletTransaction> topUpWithPaymentToken({
    required double amount,
    required String paymentToken,
  }) async {
    if (paymentToken.isEmpty) {
      throw ArgumentError('Ödəniş metodu tapılmadı');
    }

    return topUp(
      amount: amount,
      cardholderName: 'Tokenized card',
      cardNumber: '0000000000000000',
      expiryMonth: 1,
      expiryYear: 99,
      cvv: '000',
    );
  }

  @override
  Future<TopUpIntent> createTopUpIntent({required TopUpRequest request}) async {
    if (request.amount < 1 || request.amount > 5000) {
      throw ArgumentError('Məbləğ 1 və 5000 AZN arasında olmalıdır');
    }
    final id = 'top-up-${_topUpIntents.length + 1}';
    final intent = TopUpIntent(
      id: id,
      amount: request.amount,
      method: request.method.code,
      status: 'PENDING',
      invoiceNumber: 'INV-${_topUpIntents.length + 1}',
    );
    _topUpIntents[id] = intent;
    return intent;
  }

  @override
  Future<TopUpIntent> fetchTopUpIntent(String id) async {
    final intent = _topUpIntents[id];
    if (intent == null) throw StateError('Top-up intent was not found.');
    return intent;
  }

  @override
  Future<TopUpIntent> confirmTopUp(String id) async {
    final intent = await fetchTopUpIntent(id);
    if (intent.status == 'COMPLETED') return intent;
    _balance += intent.amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: id,
        amount: intent.amount,
        currency: 'AZN',
        type: TransactionType.topUp,
        status: WalletTransactionStatus.completed,
        description: 'Wallet top up',
        createdAt: DateTime.now(),
      ),
    );
    final confirmed = TopUpIntent(
      id: intent.id,
      amount: intent.amount,
      method: intent.method,
      status: 'COMPLETED',
      invoiceNumber: intent.invoiceNumber,
    );
    _topUpIntents[id] = confirmed;
    return confirmed;
  }

  @override
  Future<WalletTransaction> refund(RefundRequest request) async {
    if (request.amount <= 0) {
      throw ArgumentError('Geri ödəniş məbləği düzgün deyil');
    }
    final transaction = WalletTransaction(
      id: 'refund-${_transactions.length + 1}',
      amount: request.amount,
      currency: 'AZN',
      type: TransactionType.adjustment,
      status: WalletTransactionStatus.completed,
      description: 'Refund',
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, transaction);
    _balance += request.amount;
    return transaction;
  }
}
