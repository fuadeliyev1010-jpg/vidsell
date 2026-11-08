import 'package:vidsell/features/discover/models/subcategory.dart';
import 'package:vidsell/features/discover/repositories/subcategory_repository.dart';

class MockSubcategoryRepository implements SubcategoryRepository {
  static const Map<String, List<String>> _subcategoriesByCategory = {
    'electronics': [
      'Telefonlar',
      'Kompüterlər',
      'Planşetlər',
      'Ağıllı saatlar',
      'Qulaqlıqlar',
      'TV və Audio',
      'Oyun konsolları',
      'Aksesuarlar',
    ],
    'vehicles': [
      'Avtomobillər',
      'Motosikletlər',
      'Velosipedlər',
      'Ehtiyat hissələri',
      'Avto hissələri',
    ],
    'home-appliances': [
      'Mobilya',
      'Məişət texnikası',
      'Mətbəx əşyaları',
      'Bağ və Həyat',
      'Dekor',
    ],
    'special-occasion-clothing': [
      'Qadın geyimləri',
      'Kişi geyimləri',
      'Uşaq geyimləri',
      'Ayaqqabılar',
      'Çantalar',
      'Zinət əşyaları',
      'Saatler',
    ],
    'children': ['Oyuncaklar', 'Arabalar', 'Uşaq mebeli', 'Təhsil və kitablar'],
    'real-estate': [
      'Mənzillər',
      'Evlər',
      'Torpaq sahələri',
      'Obyektlər',
      'Kirayə',
    ],
    'cosmetics': [
      'Kosmetik məhsullar',
      'Təmir xidmətləri',
      'Təhsil xidmətləri',
      'Gözəllik xidmətləri',
      'Digər xidmətlər',
    ],
    'hobbies-sports': [
      'İdman ayaqqabıları',
      'Musiqi alətləri',
      'Kitaplar',
      'Kolleksiya əşyaları',
      'Video oyunlar',
    ],
  };

  @override
  Future<List<Subcategory>> fetchForCategory(String categoryLabel) async {
    final labels = _subcategoriesByCategory[categoryLabel] ?? const [];
    return labels
        .asMap()
        .entries
        .map(
          (entry) => Subcategory(
            id: '$categoryLabel-${entry.key + 1}',
            label: entry.value,
            categoryId: categoryLabel,
          ),
        )
        .toList(growable: false);
  }
}
