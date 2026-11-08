import 'package:vidsell/l10n/app_localizations.dart';
import 'package:vidsell/models/common/localized_enum_values.dart';

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
    final labels = LocalizedEnumValues.fromResponse(
      enumResponse,
      group: 'productSubcategory',
    );
    return List.unmodifiable([
      for (final value in response)
        if (value is String && value.trim().isNotEmpty)
          Subcategory(
            id: value.trim().toUpperCase(),
            label:
                labels[value.trim().toUpperCase()] ??
                (throw StateError(
                  'Missing localized label for subcategory ${value.trim()}.',
                )),
            categoryId: categoryId,
          )
        else
          throw StateError('Invalid product subcategory value.'),
    ]);
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
