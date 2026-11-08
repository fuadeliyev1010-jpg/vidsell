import '../enums/app_language.dart';

class AppSettings {
  const AppSettings({
    required this.language,
    required this.notificationsEnabled,
    required this.updatedAt,
  });

  final AppLanguage language;
  final bool notificationsEnabled;
  final DateTime? updatedAt;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language:
          AppLanguage.fromCode(
            (json['language'] ?? json['appLanguage'])?.toString().toUpperCase(),
          ) ??
          AppLanguage.tr,
      notificationsEnabled:
          (json['notificationsEnabled'] ?? json['notifications']) as bool? ??
          true,
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'language': language.code,
    'notificationsEnabled': notificationsEnabled,
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  static DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;
}
