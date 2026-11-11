import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/messages/model/conversation_model.dart';
import 'package:vidsell/features/messages/pages/messages_pages.dart';
import 'package:vidsell/features/messages/repositories/messaging_repository.dart';
import 'package:vidsell/l10n/app_localizations.dart';

void main() {
  testWidgets('pending conversation load is safe after the page is removed', (
    tester,
  ) async {
    final repository = _PendingMessagingRepository();

    await tester.pumpWidget(
      RepositoryProvider<MessagingRepository>.value(
        value: repository,
        child: ScreenUtilInit(
          designSize: const Size(800, 600),
          builder: (_, _) => const MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: MessagesPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    repository.conversations.complete(const []);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

class _PendingMessagingRepository implements MessagingRepository {
  final conversations = Completer<List<ConversationModel>>();

  @override
  Future<List<ConversationModel>> fetchConversations() => conversations.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
