class WalletBalance {
  const WalletBalance({
    required this.balance,
    required this.currency,
    this.updatedAt,
  });

  final double balance;
  final String currency;
  final DateTime? updatedAt;

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
    balance: (json['balance'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] as String? ?? 'TRY',
    updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
  );
}
