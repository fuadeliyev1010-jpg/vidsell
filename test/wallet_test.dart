import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/cabinet/repositories/mock_wallet_repository.dart';
import 'package:vidsell/models/enums/payment_method.dart';
import 'package:vidsell/models/wallet/top_up_request.dart';

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

  test(
    'mock top-up intent confirmation credits the wallet only once',
    () async {
      final repository = MockWalletRepository.instance;
      final before = await repository.fetchWallet();
      final intent = await repository.createTopUpIntent(
        request: TopUpRequest(
          amount: 15,
          paymentMethod: PaymentMethod.fromCode('CARD'),
        ),
      );

      await repository.confirmTopUp(intent.id);
      await repository.confirmTopUp(intent.id);

      final after = await repository.fetchWallet();
      expect(after.balance, before.balance + 15);
    },
  );

  test('top-up amount follows the documented inclusive limits', () {
    expect(TopUpRequest.isValidAmount(1), isTrue);
    expect(TopUpRequest.isValidAmount(100000), isTrue);
    expect(TopUpRequest.isValidAmount(0.99), isFalse);
    expect(TopUpRequest.isValidAmount(100000.01), isFalse);
    expect(TopUpRequest.isValidAmount(double.nan), isFalse);
  });

  test(
    'payment method parsing supports the documented values and fallback',
    () {
      expect(PaymentMethod.fromCode('CARD'), PaymentMethod.card);
      expect(
        PaymentMethod.fromCode('bank_transfer'),
        PaymentMethod.bankTransfer,
      );
      expect(PaymentMethod.fromCode('NOT_IN_CONTRACT'), PaymentMethod.unknown);
      expect(PaymentMethod.fromCode(null).isUnknown, isTrue);
    },
  );
}
