class PageResponse<T> {
  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    this.nextCursor,
  });

  final List<T> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;
  final String? nextCursor;

  @Deprecated('Use items at the API boundary.')
  List<dynamic> get listings => items;

  bool get hasMore => nextCursor != null || !last;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) => PageResponse<T>.fromData(json, fromJson);

  factory PageResponse.fromData(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson, {
    String? itemKey,
    int? requestedPage,
    bool responsePageIsZeroBased = true,
  }) {
    final map = data is Map ? Map<String, dynamic>.from(data) : const {};
    final nested = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : map;
    final rawItems = data is List
        ? data
        : map['data'] is List
        ? map['data']
        : nested[itemKey ?? 'items'] ?? nested['items'] ?? nested['content'];
    final rawPage = _int(nested['page']);
    final page = rawPage;
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((item) => fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
        : List<T>.empty(growable: false);
    return PageResponse(
      items: items,
      page: page,
      size: _int(nested['size']) == 0 ? items.length : _int(nested['size']),
      totalElements: _int(nested['totalElements']) == 0
          ? items.length
          : _int(nested['totalElements']),
      totalPages: _int(nested['totalPages']) == 0
          ? 1
          : _int(nested['totalPages']),
      last: nested['last'] is bool ? nested['last'] as bool : items.isEmpty,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) => {
    'items': items.map(toJson).toList(growable: false),
    'page': page,
    'size': size,
    'totalElements': totalElements,
    'totalPages': totalPages,
    'last': last,
  };

  static int _int(dynamic value) =>
      value is int ? value : int.tryParse('$value') ?? 0;
}
