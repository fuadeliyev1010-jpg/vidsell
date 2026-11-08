class SearchSuggestion {
  final String title;
  final String subtitle;

  const SearchSuggestion({
    required this.title,
    required this.subtitle,
    this.isAllCategories = false,
  });

  final bool isAllCategories;
}
