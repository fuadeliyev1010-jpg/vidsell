import 'package:vidsell/models/notification/app_notification.dart';

class NotificationItemModel extends AppNotification {
  const NotificationItemModel({
    required super.id,
    required super.title,
    required String description,
    required super.date,
    super.read = false,
    super.type = '',
    super.actorId,
    super.conversationId,
    super.productId,
    super.createdAt,
  }) : super(body: description);

  bool get isRead => read;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['notificationId'];
    if (id == null || '$id'.isEmpty) {
      throw const FormatException('Notification ID is missing.');
    }
    final createdAt = json['createdAt'] is String
        ? DateTime.tryParse(json['createdAt'] as String)?.toLocal()
        : null;
    final date = createdAt == null
        ? ''
        : '${createdAt.day.toString().padLeft(2, '0')}.'
              '${createdAt.month.toString().padLeft(2, '0')}.'
              '${createdAt.year}';
    return NotificationItemModel(
      id: '$id',
      title: json['title'] is String ? json['title'] as String : '',
      description: json['body'] ?? json['description'] ?? '',
      date: date,
      read:
          json['read'] == true ||
          json['isRead'] == true ||
          json['readAt'] != null,
      type: json['type'] as String? ?? '',
      actorId: json['actorId']?.toString(),
      conversationId: json['conversationId']?.toString(),
      productId: json['productId']?.toString(),
      createdAt: createdAt,
    );
  }

  @override
  NotificationItemModel copyWith({bool? read, bool? isRead}) =>
      NotificationItemModel(
        id: id,
        title: title,
        description: description,
        date: date,
        read: isRead ?? read ?? this.isRead,
        type: type,
        actorId: actorId,
        conversationId: conversationId,
        productId: productId,
        createdAt: createdAt,
      );
}
