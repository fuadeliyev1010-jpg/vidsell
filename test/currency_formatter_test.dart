import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';

void main() {
  test('formats TRY and AZN with their symbols', () {
    expect(CurrencyFormatter.formatCurrency('TRY'), '₺');
    expect(CurrencyFormatter.formatCurrency('AZN'), '₼');
  });

  test('preserves unknown currency codes and uses TRY for missing codes', () {
    expect(CurrencyFormatter.formatCurrency('USD'), 'USD');
    expect(CurrencyFormatter.formatCurrency(''), '₺');
    expect(fallbackCurrencyCode, 'TRY');
  });

  test('formats amounts without changing their values', () {
    expect(CurrencyFormatter.formatPrice(2890.24, 'AZN'), '2890.24 ₼');
    expect(
      CurrencyFormatter.formatPrice(1749, 'AZN', decimalDigits: 2),
      '1749.00 ₼',
    );
    expect(CurrencyFormatter.formatPriceText('7,00', 'TRY'), '7,00 ₺');
  });
}
