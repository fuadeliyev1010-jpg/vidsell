import 'package:vidsell/models/enums/app_language.dart';
import 'package:vidsell/models/settings/app_settings.dart';
import 'package:vidsell/features/cabinet/repositories/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  AppSettings _settings = AppSettings(
    language: AppLanguage.tr,
    notificationsEnabled: true,
    updatedAt: DateTime.now(),
  );

  @override
  Future<AppSettings> fetchSettings() async => _settings;

  @override
  Future<AppSettings> updateSettings({
    AppLanguage? language,
    bool? notificationsEnabled,
  }) async {
    _settings = AppSettings(
      language: language ?? _settings.language,
      notificationsEnabled:
          notificationsEnabled ?? _settings.notificationsEnabled,
      updatedAt: DateTime.now(),
    );
    return _settings;
  }
}
