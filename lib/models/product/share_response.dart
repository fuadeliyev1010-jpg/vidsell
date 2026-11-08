class ShareResponse {
  const ShareResponse({
    required this.productId,
    required this.shareUrl,
    required this.shareCount,
  });

  final String productId;
  final String shareUrl;
  final int shareCount;

  factory ShareResponse.fromJson(Map<String, dynamic> json) => ShareResponse(
    productId: '${json['productId'] ?? ''}',
    shareUrl: '${json['shareUrl'] ?? ''}',
    shareCount: json['shareCount'] is num
        ? (json['shareCount'] as num).toInt()
        : int.tryParse('${json['shareCount']}') ?? 0,
  );
}
