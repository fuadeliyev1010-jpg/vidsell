import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
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
    return CurrencyFormatter.formatPrice(price, currency);
  }
}
