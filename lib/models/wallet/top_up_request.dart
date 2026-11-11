import '../enums/payment_method.dart';

class TopUpRequest {
  const TopUpRequest({required this.amount, required this.paymentMethod});

  final double amount;
  final PaymentMethod paymentMethod;

  static bool isValidAmount(num amount) =>
      amount.isFinite && amount >= 1 && amount <= 100000;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'paymentMethod': paymentMethod.code,
  };
}
