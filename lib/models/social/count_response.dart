class CountResponse {
  const CountResponse({required this.markedCount});

  final int markedCount;

  factory CountResponse.fromJson(Map<String, dynamic> json) => CountResponse(
    markedCount: json['markedCount'] is num
        ? (json['markedCount'] as num).toInt()
        : 0,
  );
}
