import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/models/user/user.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._client, {SessionStore? sessionStore})
    : _sessionStore = sessionStore;

  final ApiClient _client;
  final SessionStore? _sessionStore;

  @override
  Future<User> fetchProfile() async {
    final data = await _client.get('/me');
    return _withAuthenticatedUser(_profile(data));
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String about,
    String? avatarPath,
    bool removeAvatar = false,
  }) async {
    final data = await _client.patch(
      '/me',
      data: {
        'name': name,
        'about': about,
        'avatarPath': ?avatarPath,
        'removeAvatar': removeAvatar,
      },
    );
    final profile = _profile(data);
    final updatedName = profile.name.isNotEmpty ? profile.name : name.trim();
    final updatedProfile = profile.copyWith(name: updatedName);
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
    return User(
      id: data['id'].toString(),
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      about: data['about'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      emailVerified: data['emailVerified'] as bool? ?? false,
    );
  }
}
