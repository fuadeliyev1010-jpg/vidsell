import 'package:vidsell/models/user/user.dart';

abstract interface class ProfileRepository {
  Future<User> fetchProfile();

  Future<User> updateProfile({
    required String name,
    required String about,
    String? avatarUrl,
    String? avatarPath,
    bool removeAvatar = false,
  });
}
