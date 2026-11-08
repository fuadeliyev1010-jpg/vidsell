import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/utils/currency_formatter.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/messages/pages/chat_detail_page.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';
import 'package:vidsell/l10n/app_localizations_extensions.dart';
import 'package:vidsell/models/product/product.dart';

Future<void> openSellerChat(
  BuildContext context,
  Product listing, {
  String? sellerId,
  String? sellerName,
  String? sellerAvatarUrl,
  String? initialMessage,
}) async {
  final participantName =
      (sellerName ?? listing.sellerName ?? listing.sellerHandle ?? '').trim();
  final displayName = participantName.isEmpty
      ? context.l10n.sellerLabel
      : participantName;
  final productImage = listing.imageUrls.isEmpty
      ? null
      : listing.imageUrls.first;
  try {
    final resolvedSellerId = sellerId ?? listing.sellerId;
    if (resolvedSellerId == null || resolvedSellerId.isEmpty) {
      throw StateError('Cannot start a conversation without a seller ID.');
    }
    final conversation = await context
        .read<MessagingRepository>()
        .getOrCreateConversation(
          participantId: resolvedSellerId,
          listingId: listing.id,
          participantName: displayName,
          participantAvatar: sellerAvatarUrl ?? listing.sellerAvatarUrl,
          listingTitle: listing.title,
          listingImage: productImage,
          listingPrice: CurrencyFormatter.formatPrice(
            listing.price,
            listing.currency,
          ),
        );
    if (!context.mounted) return;
    await context.goTo<void>(
      ChatDetailPage(
        conversationId: conversation.id,
        userName: conversation.participantName.isEmpty
            ? displayName
            : conversation.participantName,
        userAvatar:
            conversation.participantAvatar ??
            sellerAvatarUrl ??
            listing.sellerAvatarUrl,
        sellerId: conversation.participantId,
        listingId: conversation.listingId ?? listing.id,
        listingTitle: conversation.listingTitle ?? listing.title,
        listingImage: conversation.listingImage ?? productImage,
        listingPrice:
            conversation.listingPrice ??
            CurrencyFormatter.formatPrice(listing.price, listing.currency),
        initialMessage: initialMessage,
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
