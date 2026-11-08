class NameCount {
  const NameCount({required this.name, required this.count});

  final String name;
  final int count;

  factory NameCount.fromJson(Map<String, dynamic> json) => NameCount(
    name: '${json['name'] ?? ''}',
    count: _int(json['count']),
  );

  Map<String, dynamic> toJson() => {'name': name, 'count': count};

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
