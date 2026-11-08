import 'package:vidsell/models/settings/app_settings.dart';
import 'package:vidsell/models/enums/app_language.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> fetchSettings();

  Future<AppSettings> updateSettings({
    AppLanguage? language,
    bool? notificationsEnabled,
  });
}
