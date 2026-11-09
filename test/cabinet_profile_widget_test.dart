import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/cabinet/pages/cabinet_page.dart';
import 'package:vidsell/features/cabinet/repositories/mock_status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/mock_user_listing_repository.dart';
import 'package:vidsell/features/cabinet/repositories/profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/status_count_repository.dart';
import 'package:vidsell/features/cabinet/repositories/user_listing_repository.dart';
import 'package:vidsell/features/discover/repositories/business_repository.dart';
import 'package:vidsell/features/discover/repositories/mock_business_repository.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/user/user.dart';

void main() {
  testWidgets('cabinet displays OpenAPI user name and phone number', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profile = User.fromJson(const {
      'id': '00000000-0000-4000-8000-000000000001',
      'fullName': 'OpenAPI Test User',
      'countryCode': '+994',
      'phoneNumber': '501112233',
      'email': 'test@example.test',
      'avatarUrl': 'https://example.test/avatar.png',
      'gender': 'FEMALE',
      'role': 'BUYER',
      'createdAt': '2026-11-09T12:00:00Z',
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, child) => RepositoryProvider<BusinessRepository>.value(
          value: MockBusinessRepository.instance,
          child: RepositoryProvider<UserListingRepository>.value(
            value: MockUserListingRepository(),
            child: RepositoryProvider<StatusCountRepository>.value(
              value: MockStatusCountRepository(),
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: CabinetPage(
                  profileRepository: _TestProfileRepository(profile),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('OpenAPI Test User'), findsOneWidget);
    expect(find.text('+994 501112233'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cabinet-profile-avatar-image')),
      findsOneWidget,
    );
  });
}

class _TestProfileRepository implements ProfileRepository {
  _TestProfileRepository(this.profile);

  final User profile;

  @override
  Future<User> fetchProfile() async => profile;

  @override
  Future<User> updateProfile({
    required String name,
    required String about,
    String? avatarUrl,
    String? avatarPath,
    bool removeAvatar = false,
  }) async => profile;
}
