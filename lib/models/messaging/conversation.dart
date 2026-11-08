import '../../core/utils/currency_formatter.dart';
import '../product/product_summary.dart';
import '../user/user.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.otherUser,
    this.product,
    this.lastMessage = '',
    this.unreadCount = 0,
    this.muted = false,
    this.updatedAt,
  });

  final String id;
  final User otherUser;
  final ProductSummary? product;
  final String lastMessage;
  final int unreadCount;
  final bool muted;
  final DateTime? updatedAt;

  String get participantId => otherUser.id;
  String get participantName => otherUser.fullName;
  String? get participantAvatar => otherUser.avatarUrl;
  String? get listingId => product?.id;
  String? get listingTitle => product?.title;
  String? get listingImage => product?.imageUrl;
  String? get listingPrice => product == null
      ? null
      : CurrencyFormatter.formatPrice(product!.price, product!.currency);

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: '${json['id'] ?? ''}',
    otherUser: User.fromJson(
      json['otherUser'] is Map
          ? Map<String, dynamic>.from(json['otherUser'] as Map)
          : const <String, dynamic>{},
    ),
    product: json['product'] is Map
        ? ProductSummary.fromJson(
            Map<String, dynamic>.from(json['product'] as Map),
          )
        : null,
    lastMessage: '${json['lastMessage'] ?? ''}',
    unreadCount: json['unreadCount'] is num
        ? (json['unreadCount'] as num).toInt()
        : 0,
    muted: json['muted'] == true,
    updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
  );
}
