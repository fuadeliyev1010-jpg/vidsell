import '../enums/payment_method.dart';

class TopUpRequest {
  const TopUpRequest({required this.amount, required this.method});

  final double amount;
  final PaymentMethod method;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'method': method.code,
  };
}
