class WalletBalance {
  const WalletBalance({
    required this.balance,
    required this.currency,
    this.updatedAt,
  });

  final double balance;
  final String currency;
  final DateTime? updatedAt;
}
