class ResponseRate {
  const ResponseRate({
    required this.rate,
    this.averageResponseTimeMinutes,
  });

  final double rate;
  final int? averageResponseTimeMinutes;

  factory ResponseRate.fromJson(Map<String, dynamic> json) => ResponseRate(
    rate: json['rate'] is num
        ? (json['rate'] as num).toDouble()
        : double.tryParse('${json['rate']}') ?? 0,
    averageResponseTimeMinutes: json['averageResponseTimeMinutes'] is num
        ? (json['averageResponseTimeMinutes'] as num).toInt()
        : null,
  );
}
