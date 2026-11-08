import 'package:vidsell/features/cabinet/repositories/payment_provider.dart';

class MockPaymentProvider implements PaymentProvider {
  @override
  Future<String> tokenizeCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) async {
    if (cardholderName.trim().length < 3 ||
        cardNumber.replaceAll(' ', '').length != 16 ||
        expiryMonth < 1 ||
        expiryMonth > 12 ||
        cvv.length != 3) {
      throw ArgumentError('Kart məlumatları düzgün deyil');
    }
    return 'mock_payment_token_${DateTime.now().microsecondsSinceEpoch}';
  }
}
