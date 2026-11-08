class LikeResponse {
  const LikeResponse({
    required this.videoId,
    required this.liked,
    required this.likeCount,
  });

  final String videoId;
  final bool liked;
  final int likeCount;

  factory LikeResponse.fromJson(Map<String, dynamic> json) => LikeResponse(
    videoId: '${json['videoId'] ?? json['id'] ?? ''}',
    liked: json['liked'] == true || json['isLiked'] == true,
    likeCount: json['likeCount'] is num
        ? (json['likeCount'] as num).toInt()
        : 0,
  );
}

class LikeUser {
  const LikeUser({required this.id, required this.fullName, this.avatarUrl});

  final String id;
  final String fullName;
  final String? avatarUrl;

  factory LikeUser.fromJson(Map<String, dynamic> json) => LikeUser(
    id: '${json['id'] ?? json['userId'] ?? ''}',
    fullName: '${json['fullName'] ?? json['name'] ?? ''}',
    avatarUrl: json['avatarUrl'] as String?,
  );
}
