class ReviewRequest {
  const ReviewRequest({required this.rating, this.comment});

  final int rating;
  final String? comment;

  Map<String, dynamic> toJson() => {
    'rating': rating,
    if (comment != null) 'comment': comment,
  };
}
