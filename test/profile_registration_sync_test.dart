import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/storage/session_store.dart';
import 'package:vidsell/features/auth/repositories/mock_auth_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_profile_repository.dart';
import 'package:vidsell/models/auth/register_request.dart';
import 'package:vidsell/models/enums/gender.dart';
import 'package:vidsell/models/enums/role.dart';
import 'package:vidsell/models/user/user.dart';

void main() {
  test('profile projection keeps email identifiers out of the phone field', () {
    const user = User(
      id: 'user-2',
      identifier: 'jane@example.com',
      name: 'Jane Smith',
      email: 'jane@example.com',
    );

    expect(user.phone, isEmpty);
  });

  test('profile reads use the registered account details', () async {
    final sessionStore = await _registerTestAccount();
    final repository = MockProfileRepository(sessionStore: sessionStore);

    final profile = await repository.fetchProfile();

    expect(profile.id, 'user-1');
    expect(profile.name, 'Jane Smith');
    expect(profile.email, 'jane@example.com');
    expect(profile.phone, '+994501112233');
  });

  test(
    'profile name edits stay synchronized with the account session',
    () async {
      final sessionStore = await _registerTestAccount();
      final repository = MockProfileRepository(sessionStore: sessionStore);

      await repository.updateProfile(name: 'Jane Jones', about: '');
      final profile = await repository.fetchProfile();
      final session = await sessionStore.read();

      expect(profile.name, 'Jane Jones');
      expect(session?.user.name, 'Jane Jones');
    },
  );
}

Future<InMemorySessionStore> _registerTestAccount() async {
  final sessionStore = InMemorySessionStore();
  final authRepository = MockAuthRepository(sessionStore: sessionStore);
  await authRepository.register(
    const RegisterRequest(
      fullName: 'Jane Smith',
      countryCode: '+994',
      phoneNumber: '501112233',
      password: 'password',
      email: 'jane@example.com',
      gender: Gender.female,
      termsAccepted: true,
      role: Role.buyer,
      verificationCode: '1234',
    ),
  );
  return sessionStore;
}
