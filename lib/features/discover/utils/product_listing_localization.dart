import 'package:vidsell/features/discover/models/product_listing.dart';
import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/product/product.dart';

extension ProductLocalization on Product {
  String localizedLocation(AppLocalizations l10n) {
    final location = city?.isNotEmpty == true ? city! : 'İstanbul';
    return switch (location) {
      'Bakı' => l10n.cityBaku,
      'İstambul' || 'İstanbul' => l10n.cityIstanbul,
      'Nərimanov' => l10n.districtNarimanov,
      'Sahil' => l10n.districtSahil,
      'Yasamal' => l10n.districtYasamal,
      'Gənclik' => l10n.districtGanjlik,
      _ => location,
    };
  }

  String get formattedPrice {
    if (price == 0 && currency.isEmpty && sellerName?.isNotEmpty == true) {
      return sellerName!;
    }
    final amount = price % 1 == 0 ? price.toInt().toString() : price.toString();
    return '$amount $currency'.trim();
  }
}

extension ProductListingLocalization on ProductListing {
  String localizedLocation(AppLocalizations l10n) => switch (location) {
    'Bakı' => l10n.cityBaku,
    'İstambul' || 'İstanbul' => l10n.cityIstanbul,
    'Nərimanov' => l10n.districtNarimanov,
    'Sahil' => l10n.districtSahil,
    'Yasamal' => l10n.districtYasamal,
    'Gənclik' => l10n.districtGanjlik,
    _ => location,
  };

  String localizedTimeAgo(AppLocalizations l10n) {
    final match = RegExp(
      r'^(\d+)\s*(saat|hour|hours|gün|day|days)$',
    ).firstMatch(timeAgo.trim().toLowerCase());
    if (match == null) return timeAgo;

    final count = int.tryParse(match.group(1)!);
    if (count == null) return timeAgo;
    return switch (match.group(2)) {
      'saat' || 'hour' || 'hours' => l10n.hoursAgo(count),
      _ => l10n.dayAgo(count),
    };
  }
}
