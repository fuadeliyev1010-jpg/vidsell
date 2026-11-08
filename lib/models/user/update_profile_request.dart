class UpdateProfileRequest {
  const UpdateProfileRequest({this.fullName, this.avatarUrl});

  final String? fullName;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    if (fullName != null) 'fullName': fullName,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}
