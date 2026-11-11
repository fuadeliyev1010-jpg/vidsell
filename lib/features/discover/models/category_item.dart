import 'package:vidsell/l10n/app_localizations.dart';

class CategoryItem {
  final String id;
  final String label;
  final String iconPath;
  final String? secondIconPath;

  const CategoryItem({
    required this.id,
    required this.label,
    required this.iconPath,
    this.secondIconPath,
  });

  String? get apiCode => switch (id) {
    'electronics' => 'ELECTRONICS',
    'vehicles' => 'TRANSPORT',
    'home-appliances' => 'HOME_APPLIANCES',
    'special-occasion-clothing' => 'SPECIAL_OCCASION',
    'real-estate' => 'REAL_ESTATE',
    'cosmetics' => 'COSMETICS',
    _ => null,
  };

  static const List<CategoryItem> categories = [
    CategoryItem(
      id: 'catalog',
      label: 'Katalog',
      iconPath: 'assets/images/category.svg',
    ),
    CategoryItem(
      id: 'electronics',
      label: 'Elektronik',
      iconPath: 'assets/images/computer 2.png',
      secondIconPath: 'assets/images/computer 3.png',
    ),
    CategoryItem(
      id: 'vehicles',
      label: 'Araçlar',
      iconPath: 'assets/images/1783940868861 2.png',
      secondIconPath: 'assets/images/teker 3.png',
    ),
    CategoryItem(
      id: 'home-appliances',
      label: 'Ev Aletleri',
      iconPath: 'assets/images/926bcfbeec27a3806adb0f4ad168fa2c 2.png',
      secondIconPath: 'assets/images/926bcfbeec27a3806adb0f4ad168fa2c 3.png',
    ),
    CategoryItem(
      id: 'special-occasion-clothing',
      label: 'Özel Gün Kiyafetleri',
      iconPath: 'assets/images/palto 2.png',
      secondIconPath: 'assets/images/ceket 3.png',
    ),
    CategoryItem(
      id: 'real-estate',
      label: 'Emlak',
      iconPath: 'assets/images/ev 2.png',
      secondIconPath: 'assets/images/20260626_191006 3.png',
    ),
    CategoryItem(
      id: 'cosmetics',
      label: 'Kozmetik',
      iconPath: 'assets/images/iş çantası 2.png',
      secondIconPath: 'assets/images/iş 3.png',
    ),
  ];
}

extension CategoryItemLocalization on CategoryItem {
  String localizedLabel(AppLocalizations l10n) => switch (id) {
    'catalog' => l10n.categoryCatalog,
    'electronics' => l10n.categoryElectronics,
    'vehicles' => l10n.categoryVehicles,
    'home-appliances' => l10n.categoryHomeAppliances,
    'special-occasion-clothing' => l10n.categorySpecialClothing,
    'real-estate' => l10n.categoryRealEstate,
    'cosmetics' => l10n.categoryCosmetics,
    _ => label,
  };
}
