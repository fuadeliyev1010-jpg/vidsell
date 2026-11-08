class Review {
  const Review({
    required this.id,
    required this.authorId,
    required this.authorFullName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.authorAvatarUrl,
  });

  final String id;
  final String authorId;
  final String authorFullName;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final String? authorAvatarUrl;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: '${json['id'] ?? ''}',
    authorId: '${json['authorId'] ?? json['userId'] ?? ''}',
    authorFullName:
        '${json['authorFullName'] ?? json['authorName'] ?? json['userName'] ?? ''}',
    rating: json['rating'] is num
        ? (json['rating'] as num).toDouble()
        : double.tryParse('${json['rating'] ?? 0}') ?? 0,
    comment: '${json['comment'] ?? json['content'] ?? ''}',
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    authorAvatarUrl: json['authorAvatarUrl'] as String?,
  );
}
