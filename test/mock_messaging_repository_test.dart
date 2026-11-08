import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/messages/repositories/mock_messaging_repository.dart';

void main() {
  test(
    'keeps conversations and sent messages available by stable ID',
    () async {
      final repository = MockMessagingRepository.instance;
      final conversation = await repository.getOrCreateConversation(
        participantId: 'seller-persistence-test',
        listingId: 'listing-persistence-test',
        participantName: 'Seller',
        listingTitle: 'Camera',
      );
      final reopened = await repository.getOrCreateConversation(
        participantId: 'seller-persistence-test',
        listingId: 'listing-persistence-test',
        participantName: 'Seller',
        listingTitle: 'Camera',
      );
      final sent = await repository.sendMessage(conversation.id, 'Hello');
      final messages = await repository.fetchMessages(conversation.id);

      expect(reopened.id, conversation.id);
      expect(sent.id, isNotEmpty);
      expect(messages.map((message) => message.id), [sent.id]);
      expect(messages.single.conversationId, conversation.id);
    },
  );
}
