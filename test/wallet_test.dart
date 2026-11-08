import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/cabinet/repositories/mock_wallet_repository.dart';

void main() {
  test('mock wallet completes a top-up and updates balance', () async {
    final repository = MockWalletRepository.instance;
    final before = await repository.fetchWallet();

    final transaction = await repository.topUp(
      amount: 10,
      cardholderName: 'Test User',
      cardNumber: '4111111111111111',
      expiryMonth: 12,
      expiryYear: 30,
      cvv: '123',
    );

    final after = await repository.fetchWallet();
    expect(transaction.amount, 10);
    expect(transaction.status.name, 'completed');
    expect(after.balance, before.balance + 10);
  });

  test('mock wallet rejects invalid card data', () async {
    expect(
      () => MockWalletRepository.instance.topUp(
        amount: 10,
        cardholderName: 'Test User',
        cardNumber: '123',
        expiryMonth: 12,
        expiryYear: 30,
        cvv: '123',
      ),
      throwsArgumentError,
    );
  });
}
