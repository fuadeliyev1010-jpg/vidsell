import 'package:vidsell/features/cabinet/repositories/payment_provider.dart';

class ApiPaymentProvider implements PaymentProvider {
  const ApiPaymentProvider();

  @override
  Future<String> tokenizeCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) async {
    throw UnsupportedError(
      'Configure the selected PSP mobile SDK before enabling API payments.',
    );
  }
}
