import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/features/home/models/home_listing.dart';
import 'package:vidsell/features/messages/pages/chat_detail_page.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';

Future<void> openSellerChat(
  BuildContext context,
  HomeListing listing, {
  String? initialMessage,
}) async {
  final sellerName = listing.sellerName.trim();
  try {
    final sellerId = listing.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      throw StateError('Cannot start a conversation without a seller ID.');
    }
    final conversation = await context
        .read<MessagingRepository>()
        .getOrCreateConversation(
          participantId: sellerId,
          listingId: listing.id,
          participantName: sellerName.isEmpty ? 'Satıcı' : sellerName,
          participantAvatar: listing.sellerAvatar,
          listingTitle: listing.title,
          listingImage: listing.imagePath,
          listingPrice: listing.price,
        );
    if (!context.mounted) return;
    await context.goTo<void>(
      ChatDetailPage(
        conversationId: conversation.id,
        userName: conversation.participantName.isEmpty
            ? (sellerName.isEmpty ? 'Satıcı' : sellerName)
            : conversation.participantName,
        userAvatar: conversation.participantAvatar ?? listing.sellerAvatar,
        sellerId: conversation.participantId,
        listingId: conversation.listingId ?? listing.id,
        listingTitle: conversation.listingTitle ?? listing.title,
        listingImage: conversation.listingImage ?? listing.imagePath,
        listingPrice: conversation.listingPrice ?? listing.price,
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
