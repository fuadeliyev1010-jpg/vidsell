abstract interface class PaymentProvider {
  Future<String> tokenizeCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  });
}
