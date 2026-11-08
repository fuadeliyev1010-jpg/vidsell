import 'package:vidsell/models/messaging/conversation.dart';
import 'package:vidsell/models/product/product_summary.dart';
import 'package:vidsell/models/user/user.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required String participantId,
    required String participantName,
    required super.lastMessage,
    required super.updatedAt,
    required super.unreadCount,
    String? participantAvatar,
    String? listingId,
    String? listingTitle,
    String? listingImage,
    String? listingPrice,
    super.muted = false,
  }) : super(
         otherUser: User(
           id: participantId,
           fullName: participantName,
           avatarUrl: participantAvatar,
         ),
         product: listingId == null
             ? null
             : ProductSummary(
                 id: listingId,
                 title: listingTitle ?? '',
                 price: double.tryParse(listingPrice ?? '') ?? 0,
                 currency: '',
                 city: '',
                 imageUrl: listingImage,
               ),
       );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participant =
        _map(json['otherParticipant']) ??
        _map(json['participant']) ??
        _map(json['seller']) ??
        const <String, dynamic>{};
    final listing = _map(json['listing']) ?? const <String, dynamic>{};
    final lastMessage = _map(json['lastMessage']);
    final id = _string(json['id'] ?? json['conversationId']);
    if (id.isEmpty) throw const FormatException('Conversation ID is missing.');
    return ConversationModel(
      id: id,
      participantId: _string(
        participant['id'] ?? json['participantId'] ?? json['sellerId'],
      ),
      participantName: _string(
        participant['name'] ??
            participant['displayName'] ??
            json['participantName'] ??
            json['sellerName'],
      ),
      participantAvatar: participant['avatarUrl'] as String?,
      listingId: _nullable(listing['id'] ?? json['listingId']),
      listingTitle: _nullable(listing['title'] ?? json['listingTitle']),
      listingImage: _nullable(listing['imageUrl'] ?? json['listingImage']),
      listingPrice: _display(
        listing['priceLabel'] ?? listing['price'] ?? json['listingPrice'],
      ),
      lastMessage: _string(
        lastMessage?['text'] ?? lastMessage?['body'] ?? json['lastMessageText'],
      ),
      updatedAt: _date(
        json['updatedAt'] ?? json['lastMessageAt'] ?? lastMessage?['createdAt'],
      ),
      unreadCount: json['unreadCount'] is int ? json['unreadCount'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'participantId': participantId,
    'participantName': participantName,
    'participantAvatar': participantAvatar,
    'listingId': listingId,
    'listingTitle': listingTitle,
    'listingImage': listingImage,
    'listingPrice': listingPrice,
    'lastMessage': lastMessage,
    'updatedAt': updatedAt?.toIso8601String(),
    'unreadCount': unreadCount,
  };

  static Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
  static String _string(dynamic value) => value is String ? value : '';
  static String? _nullable(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;
  static String? _display(dynamic value) => value is String
      ? value
      : value is num
      ? value.toString()
      : null;
  static DateTime? _date(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;
}
