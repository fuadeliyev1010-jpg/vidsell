import 'package:flutter/foundation.dart';
import 'package:vidsell/features/discover/models/subcategory_category_map.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class Subcategory {
  const Subcategory({
    required this.id,
    required this.label,
    required this.categoryId,
  });

  final String id;
  final String label;
  final String categoryId;

  static List<Subcategory> fromApiResponse(
    dynamic response,
    dynamic enumResponse, {
    required String categoryId,
  }) {
    if (response is! List) {
      throw StateError('Invalid product subcategories response.');
    }
    final categoryCode = switch (categoryId.toLowerCase()) {
      'electronics' => 'ELECTRONICS',
      'vehicles' || 'transport' => 'TRANSPORT',
      'real-estate' => 'REAL_ESTATE',
      'home-appliances' => 'HOME_APPLIANCES',
      'special-occasion-clothing' => 'SPECIAL_OCCASION',
      'cosmetics' => 'COSMETICS',
      _ => categoryId.toUpperCase(),
    };
    final allowedValues = subcategoryCategoryMap[categoryCode] ?? const [];
    final labels = _labels(enumResponse);
    final seenValues = <String>{};
    final knownValues = subcategoryCategoryMap.values
        .expand((values) => values)
        .toSet();
    final subcategories = <Subcategory>[];
    for (final value in response) {
      if (value is! String || value.trim().isEmpty) {
        throw StateError('Invalid product subcategory value.');
      }
      final code = value.trim().toUpperCase();
      if (!knownValues.contains(code)) {
        _logUnknownSubcategory(code);
        continue;
      }
      if (!seenValues.add(code) || !allowedValues.contains(code)) continue;
      subcategories.add(
        Subcategory(
          id: code,
          label: labels[code] ?? code,
          categoryId: categoryId,
        ),
      );
    }
    return List.unmodifiable(subcategories);
  }

  static Map<String, String> _labels(dynamic response) {
    if (response is! Map) {
      throw StateError('Invalid enum localization response.');
    }
    final root = Map<String, dynamic>.from(response);
    final groups = root['groups'] is Map
        ? Map<String, dynamic>.from(root['groups'] as Map)
        : root;
    final values = groups['productSubcategory'];
    if (values is! List) {
      throw StateError('The productSubcategory enum group is missing.');
    }
    return {
      for (final item in values)
        if (item is Map && item['value'] is String)
          (item['value'] as String).toUpperCase():
              item['labelTr'] is String &&
                  (item['labelTr'] as String).isNotEmpty
              ? item['labelTr'] as String
              : item['value'] as String,
    };
  }

  static void _logUnknownSubcategory(String value) {
    if (kDebugMode) {
      debugPrint('[Subcategory] Ignoring unmapped backend value: $value');
    }
  }
}

extension SubcategoryLocalization on Subcategory {
  String localizedLabel(AppLocalizations l10n) => switch (label) {
    'Telefonlar' => l10n.categoryPhones,
    'Kompüterlər' => l10n.subcategoryComputers,
    'Planşetlər' => l10n.subcategoryTablets,
    'Ağıllı saatlar' => l10n.subcategorySmartWatches,
    'Qulaqlıqlar' => l10n.subcategoryHeadphones,
    'TV və Audio' => l10n.subcategoryTvAudio,
    'Oyun konsolları' => l10n.subcategoryGameConsoles,
    'Aksesuarlar' => l10n.subcategoryAccessories,
    'Avtomobillər' => l10n.subcategoryCars,
    'Motosikletlər' => l10n.subcategoryMotorcycles,
    'Velosipedlər' => l10n.subcategoryBicycles,
    'Ehtiyat hissələri' => l10n.subcategorySpareParts,
    'Avto hissələri' => l10n.subcategoryAutoParts,
    'Mobilya' => l10n.subcategoryFurniture,
    'Məişət texnikası' => l10n.subcategoryHomeAppliances,
    'Mətbəx əşyaları' => l10n.subcategoryKitchenware,
    'Bağ və Həyat' => l10n.subcategoryGardenLifestyle,
    'Dekor' => l10n.subcategoryDecor,
    'Qadın geyimləri' => l10n.subcategoryWomenClothing,
    'Kişi geyimləri' => l10n.subcategoryMenClothing,
    'Uşaq geyimləri' => l10n.subcategoryChildrenClothing,
    'Ayaqqabılar' => l10n.subcategoryShoes,
    'Çantalar' => l10n.subcategoryBags,
    'Zinət əşyaları' => l10n.subcategoryJewelry,
    'Saatler' => l10n.subcategoryWatches,
    'Oyuncaklar' => l10n.subcategoryToys,
    'Arabalar' => l10n.subcategoryStrollers,
    'Uşaq mebeli' => l10n.subcategoryChildFurniture,
    'Təhsil və kitablar' => l10n.subcategoryEducationBooks,
    'Mənzillər' => l10n.subcategoryApartments,
    'Evlər' => l10n.subcategoryHouses,
    'Torpaq sahələri' => l10n.subcategoryLand,
    'Obyektlər' => l10n.subcategoryCommercialProperty,
    'Kirayə' => l10n.subcategoryRent,
    'Kosmetik məhsullar' => l10n.subcategoryCosmetics,
    '?? f?rsatlar?' => l10n.subcategoryCosmetics,
    'Təmir xidmətləri' => l10n.subcategoryRepairServices,
    'Təhsil xidmətləri' => l10n.subcategoryEducationServices,
    'Gözəllik xidmətləri' => l10n.subcategoryBeautyServices,
    'Digər xidmətlər' => l10n.subcategoryOtherServices,
    'İdman ayaqqabıları' => l10n.subcategorySportsShoes,
    'Musiqi alətləri' => l10n.subcategoryMusicalInstruments,
    'Kitaplar' => l10n.subcategoryBooks,
    'Kolleksiya əşyaları' => l10n.subcategoryCollectibles,
    'Video oyunlar' => l10n.subcategoryVideoGames,
    _ => label,
  };
}
