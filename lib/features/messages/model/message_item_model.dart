class MessageItemModel {
  final String id;
  final String title;
  final String sender;
  final String lastMessage;
  final String date;
  final String avatarUrl;
  final bool isOnline;
  final int unreadCount;

  MessageItemModel({
    required this.id,
    required this.title,
    required this.sender,
    required this.lastMessage,
    required this.date,
    required this.avatarUrl,
    required this.isOnline,
    this.unreadCount = 0,
  });
}
