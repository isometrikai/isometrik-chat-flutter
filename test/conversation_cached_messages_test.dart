import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

IsmChatMessageModel _msg(String id) => IsmChatMessageModel(
      body: id,
      customType: IsmChatCustomMessageType.text,
      sentAt: 1,
      sentByMe: true,
      messageId: id,
    );

void main() {
  group('IsmChatConversationCachedMessages', () {
    test('withCachedMessagesFrom copies Hive history onto a list stub', () {
      final stub = IsmChatConversationModel(
        conversationId: 'c1',
        unreadMessagesCount: 3,
        messages: const {},
      );
      final hive = IsmChatConversationModel(
        conversationId: 'c1',
        messages: {'1': _msg('1'), '2': _msg('2')},
      );

      final merged = stub.withCachedMessagesFrom(hive);

      expect(merged.hasCachedMessages, isTrue);
      expect(merged.unreadMessagesCount, 3);
      expect(merged.messages, hive.messages);
    });

    test('withCachedMessagesFrom keeps existing messages', () {
      final local = IsmChatConversationModel(
        conversationId: 'c1',
        messages: {'a': _msg('a')},
      );
      final hive = IsmChatConversationModel(
        conversationId: 'c1',
        messages: {'b': _msg('b'), 'c': _msg('c')},
      );

      final merged = local.withCachedMessagesFrom(hive);

      expect(merged.messages, local.messages);
    });

    test('withCachedMessagesFrom is a no-op when cache is empty', () {
      final stub = IsmChatConversationModel(
        conversationId: 'c1',
        messages: const {},
      );

      expect(stub.withCachedMessagesFrom(null).messages, isEmpty);
      expect(
        stub
            .withCachedMessagesFrom(
              IsmChatConversationModel(conversationId: 'c1', messages: const {}),
            )
            .hasCachedMessages,
        isFalse,
      );
    });
  });
}
