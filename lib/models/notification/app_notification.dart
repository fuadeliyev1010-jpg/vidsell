class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.date = '',
    this.actorId,
    this.conversationId,
    this.productId,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String? actorId;
  final String? conversationId;
  final String? productId;
  final bool read;
  final DateTime? createdAt;
  final String date;
  String get description => body;

  AppNotification copyWith({bool? read, bool? isRead}) => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    actorId: actorId,
    conversationId: conversationId,
    productId: productId,
    read: isRead ?? read ?? this.read,
    createdAt: createdAt,
    date: date,
  );
}
