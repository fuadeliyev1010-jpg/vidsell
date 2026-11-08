class CommentRequest {
  const CommentRequest({required this.content});

  final String content;

  Map<String, dynamic> toJson() => {'content': content};
}
