import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/models/user/user.dart';

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({SessionStore? sessionStore})
    : _sessionStore = sessionStore;

  static final instance = MockProfileRepository();

  final SessionStore? _sessionStore;

  User _profile = const User(
    id: 'mock-user-1',
    name: 'Həsən Məmmədov',
    email: 'hasan@example.com',
    phone: '+994123456789',
    phoneVerified: true,
  );

  @override
  Future<User> fetchProfile() async {
    final sessionStore = _sessionStore;
    if (sessionStore == null) return _profile;
    final session = await sessionStore.read();
    if (session == null) return _profile;
    final user = session.user;
    final profile = _profile.copyWith(
      id: user.id.isNotEmpty ? user.id : null,
      name: user.name.isNotEmpty ? user.name : null,
      email: user.email.isNotEmpty ? user.email : null,
      phoneNumber: user.phone.isNotEmpty
          ? user.phone
          : user.identifier.contains('@')
          ? ''
          : user.identifier,
      about: user.about,
      avatarUrl: user.avatarUrl,
      phoneVerified: user.phoneVerified,
      emailVerified: user.emailVerified,
    );
    return profile;
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String about,
    String? avatarUrl,
    String? avatarPath,
    bool removeAvatar = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final updatedAvatar = removeAvatar || avatarUrl == ''
        ? _profile.copyWith(clearAvatar: true)
        : avatarUrl != null
        ? _profile.copyWith(avatarUrl: avatarUrl)
        : avatarPath == null
        ? _profile
        : _profile.copyWith(avatarUrl: 'mock://avatar/$avatarPath');
    _profile = updatedAvatar.copyWith(name: name.trim(), about: about.trim());
    final sessionStore = _sessionStore;
    if (sessionStore != null) {
      final session = await sessionStore.read();
      if (session != null) {
        await sessionStore.write(
          session.copyWith(
            user: _profile.copyWith(identifier: session.user.identifier),
          ),
        );
      }
    }
    return _profile;
  }
}
