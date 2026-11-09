import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/core/config/app_environment.dart';
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/cabinet/repositories/api_profile_repository.dart';
import 'package:vidsell/features/cabinet/repositories/api_settings_repository.dart';
import 'package:vidsell/models/enums/app_language.dart';

void main() {
  test(
    'profile repositories use the OpenAPI paths, verbs, and request body',
    () async {
      final adapter = _ProfileSettingsAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test/api/v1',
          useMockBackend: false,
        ),
        dio: dio,
      );
      addTearDown(() {
        client.dispose();
        dio.close(force: true);
      });

      final profileRepository = ApiProfileRepository(client);
      final settingsRepository = ApiSettingsRepository(client);

      final profile = await profileRepository.fetchProfile();
      expect(profile.fullName, 'Test User');
      final updatedProfile = await profileRepository.updateProfile(
        name: 'Updated User',
        about: '',
        avatarUrl: 'https://example.test/updated-avatar.png',
      );
      expect(updatedProfile.fullName, 'Updated User');
      expect(
        updatedProfile.avatarUrl,
        'https://example.test/updated-avatar.png',
      );

      await settingsRepository.fetchSettings();
      await settingsRepository.updateSettings(
        language: AppLanguage.en,
        notificationsEnabled: false,
      );

      expect(
        adapter.requests.map((request) => (request.method, request.path)),
        [
          ('GET', '/users/me'),
          ('PUT', '/users/me'),
          ('GET', '/settings'),
          ('PUT', '/settings'),
        ],
      );
      expect(adapter.requests[1].data, {
        'fullName': 'Updated User',
        'avatarUrl': 'https://example.test/updated-avatar.png',
      });
      expect(adapter.requests[3].data, {
        'language': 'EN',
        'notificationsEnabled': false,
      });
      expect(
        adapter.requests.map((request) => request.headers['X-App-Language']),
        everyElement('tr'),
      );
    },
  );
}

class _ProfileSettingsAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = switch ((options.method, options.path)) {
      ('GET', '/users/me') => _userResponse('Test User'),
      ('PUT', '/users/me') => _userResponse('Updated User'),
      ('GET', '/settings') => {
        'language': 'TR',
        'notificationsEnabled': true,
        'updatedAt': '2026-11-09T12:00:00Z',
      },
      ('PUT', '/settings') => {
        'language': 'EN',
        'notificationsEnabled': false,
        'updatedAt': '2026-11-09T12:00:00Z',
      },
      _ => throw StateError(
        'Unexpected profile/settings route: ${options.method} ${options.path}',
      ),
    };
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  Map<String, dynamic> _userResponse(String fullName) => {
    'id': '00000000-0000-4000-8000-000000000001',
    'fullName': fullName,
    'countryCode': '+994',
    'phoneNumber': '501112233',
    'email': 'test@example.test',
    'avatarUrl': fullName == 'Test User'
        ? 'https://example.test/avatar.png'
        : 'https://example.test/updated-avatar.png',
    'gender': 'FEMALE',
    'role': 'BUYER',
    'createdAt': '2026-11-09T12:00:00Z',
  };

  @override
  void close({bool force = false}) {}
}
