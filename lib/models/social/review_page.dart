import 'review.dart';

class ReviewPage {
  const ReviewPage({
    required this.averageRating,
    required this.reviewCount,
    required this.items,
  });

  final double averageRating;
  final int reviewCount;
  final List<Review> items;

  factory ReviewPage.fromJson(Map<String, dynamic> json) => ReviewPage(
    averageRating: json['averageRating'] is num
        ? (json['averageRating'] as num).toDouble()
        : 0,
    reviewCount: json['reviewCount'] is num
        ? (json['reviewCount'] as num).toInt()
        : 0,
    items: json['items'] is List
        ? (json['items'] as List)
              .whereType<Map>()
              .map((item) => Review.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
        : const [],
  );
}
