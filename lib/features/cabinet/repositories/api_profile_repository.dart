import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/models/user/update_profile_request.dart';
import 'package:vidsell/models/user/user.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._client, {SessionStore? sessionStore})
    : _sessionStore = sessionStore;

  final ApiClient _client;
  final SessionStore? _sessionStore;

  @override
  Future<User> fetchProfile() async {
    final data = await _client.get('/users/me');
    return _withAuthenticatedUser(_profile(data));
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String about,
    String? avatarUrl,
    String? avatarPath,
    bool removeAvatar = false,
  }) async {
    final data = await _client.put(
      '/users/me',
      data: UpdateProfileRequest(
        fullName: name.trim(),
        avatarUrl: removeAvatar ? '' : avatarUrl,
      ).toJson(),
    );
    final profile = _profile(data);
    final updatedProfile = profile.copyWith(
      fullName: profile.fullName.isNotEmpty ? profile.fullName : name.trim(),
      avatarUrl: profile.avatarUrl ?? avatarUrl,
    );
    await _saveAuthenticatedProfile(updatedProfile);
    return updatedProfile;
  }

  Future<User> _withAuthenticatedUser(User profile) async {
    final sessionStore = _sessionStore;
    if (sessionStore == null) return profile;
    final session = await sessionStore.read();
    if (session == null) return profile;
    final user = session.user;
    final updatedUser = profile.copyWith(
      identifier: profile.phone.isNotEmpty ? profile.phone : user.identifier,
    );
    await sessionStore.write(session.copyWith(user: updatedUser));
    return updatedUser;
  }

  Future<void> _saveAuthenticatedProfile(User profile) async {
    final sessionStore = _sessionStore;
    if (sessionStore == null) return;
    final session = await sessionStore.read();
    if (session == null) return;
    await sessionStore.write(
      session.copyWith(
        user: profile.copyWith(identifier: session.user.identifier),
      ),
    );
  }

  User _profile(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid profile response.');
    }
    return User.fromJson(data);
  }
}
