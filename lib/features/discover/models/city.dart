import 'package:vidsell/l10n/app_localizations.dart';

class City {
  const City({required this.id, required this.name});

  final String id;
  final String name;
}

extension CityLocalization on City {
  String localizedName(AppLocalizations l10n) => switch (id) {
    'istanbul' => l10n.cityIstanbul,
    _ => name,
  };
}
