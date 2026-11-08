class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.query,
    required this.createdAt,
  });

  final String id;
  final String query;
  final DateTime createdAt;

  factory SavedSearch.fromJson(Map<String, dynamic> json) => SavedSearch(
    id: json['id'].toString(),
    query: json['query'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
