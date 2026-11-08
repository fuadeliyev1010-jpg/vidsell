const fallbackCurrencyCode = 'TRY';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String formatCurrency(String? currencyCode) {
    final code = currencyCode?.trim().toUpperCase();
    return switch (code) {
      null || '' => formatCurrency(fallbackCurrencyCode),
      'TRY' => '₺',
      'AZN' => '₼',
      _ => code,
    };
  }

  static String formatPrice(
    num amount,
    String? currencyCode, {
    int? decimalDigits,
  }) {
    final formattedAmount = decimalDigits == null
        ? amount % 1 == 0
              ? amount.toInt().toString()
              : amount.toString()
        : amount.toStringAsFixed(decimalDigits);
    return '$formattedAmount ${formatCurrency(currencyCode)}';
  }

  static String formatPriceText(String amount, String? currencyCode) =>
      '$amount ${formatCurrency(currencyCode)}';
}
