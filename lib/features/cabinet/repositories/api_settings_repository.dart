import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/models/enums/app_language.dart';
import 'package:vidsell/models/settings/app_settings.dart';
import 'package:vidsell/features/cabinet/repositories/settings_repository.dart';

class ApiSettingsRepository implements SettingsRepository {
  ApiSettingsRepository(this._client);

  final ApiClient _client;

  @override
  Future<AppSettings> fetchSettings() async {
    final data = await _client.get('/settings');
    return _parse(data);
  }

  @override
  Future<AppSettings> updateSettings({
    AppLanguage? language,
    bool? notificationsEnabled,
  }) async {
    final data = await _client.patch(
      '/settings',
      data: {
        'language': ?language?.code,
        'notificationsEnabled': ?notificationsEnabled,
      },
    );
    return _parse(data);
  }

  AppSettings _parse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid settings response.');
    }
    return AppSettings.fromJson(data);
  }
}
