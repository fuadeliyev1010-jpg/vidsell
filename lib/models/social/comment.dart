class Comment {
  const Comment({
    required this.id,
    required this.videoId,
    required this.authorId,
    required this.authorFullName,
    required this.content,
    required this.createdAt,
    this.authorAvatarUrl,
  });

  final String id;
  final String videoId;
  final String authorId;
  final String authorFullName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime? createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: '${json['id'] ?? ''}',
    videoId: '${json['videoId'] ?? _videoId(json['video'])}',
    authorId: '${json['authorId'] ?? json['userId'] ?? ''}',
    authorFullName:
        '${json['authorFullName'] ?? json['authorName'] ?? json['userName'] ?? ''}',
    authorAvatarUrl:
        json['authorAvatarUrl'] as String? ?? json['userAvatarUrl'] as String?,
    content: '${json['content'] ?? ''}',
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
  );

  static String _videoId(dynamic value) =>
      value is Map ? '${value['id'] ?? ''}' : '';
}
