import 'package:vidsell/models/notification/app_notification.dart';

class NotificationItemModel extends AppNotification {
  const NotificationItemModel({
    required super.id,
    required super.title,
    required String description,
    required super.date,
    super.read = false,
  }) : super(type: '', body: description, createdAt: null);

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
      description: json['description'] ?? json['body'] ?? '',
      date: date,
      read: json['isRead'] == true || json['readAt'] != null,
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
      );
}
