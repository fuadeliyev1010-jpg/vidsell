import 'package:vidsell/models/wallet/top_up_request.dart';
import 'package:vidsell/models/enums/payment_method.dart';
import 'package:vidsell/models/wallet/wallet_balance.dart';
import 'package:vidsell/models/wallet/wallet_transaction.dart';
import 'package:vidsell/models/wallet/top_up_intent.dart';

abstract interface class WalletRepository {
  Future<WalletBalance> fetchWallet();

  Future<List<WalletTransaction>> fetchTransactions();

  Future<List<PaymentMethodOption>> fetchPaymentMethods();

  /// Direct top-up with raw card credentials.
  ///
  /// NOTE: This method is intended for mock and testing environments.
  /// In production, tokenize the card via `PaymentProvider.tokenizeCard`
  /// and invoke [topUpWithPaymentToken] to maintain PCI-DSS compliance.
  Future<WalletTransaction> topUp({
    required double amount,
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  });

  Future<WalletTransaction> topUpWithPaymentToken({
    required double amount,
    required String paymentToken,
  });

  Future<TopUpIntent> createTopUpIntent({required TopUpRequest request});

  Future<TopUpIntent> fetchTopUpIntent(String id);

  Future<TopUpIntent> confirmTopUp(String id);

  Future<WalletTransaction> refund(RefundRequest request);
}
