import 'package:vidsell/features/discover/models/subcategory.dart';

abstract interface class SubcategoryRepository {
  Future<List<String>> fetchCategories();

  Future<List<Subcategory>> fetchForCategory(String categoryId);
}
