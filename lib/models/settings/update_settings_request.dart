import '../enums/app_language.dart';

class UpdateSettingsRequest {
  const UpdateSettingsRequest({this.language, this.notificationsEnabled});

  final AppLanguage? language;
  final bool? notificationsEnabled;

  Map<String, dynamic> toJson() => {
    if (language != null) 'language': language!.code,
    if (notificationsEnabled != null)
      'notificationsEnabled': notificationsEnabled,
  };
}
