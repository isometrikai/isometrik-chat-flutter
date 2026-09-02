import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

IsmChatMessageModel _msg({
  required String id,
  required int sentAt,
  IsmChatCustomMessageType type = IsmChatCustomMessageType.text,
}) =>
    IsmChatMessageModel(
      body: id,
      customType: type,
      sentAt: sentAt,
      sentByMe: true,
      messageId: id,
    );

void main() {
  group('IsmChatPageViewModel.reversedScrollIndexForMessageId', () {
    test('uses reverse ListView indexes so newest is 0', () {
      final messages = [
        _msg(id: 'oldest', sentAt: 1),
        _msg(id: 'middle', sentAt: 2),
        _msg(id: 'newest', sentAt: 3),
      ];

      expect(
        IsmChatPageViewModel.reversedScrollIndexForMessageId(
          messages,
          messageId: 'newest',
        ),
        0,
      );
      expect(
        IsmChatPageViewModel.reversedScrollIndexForMessageId(
          messages,
          messageId: 'oldest',
        ),
        2,
      );
    });

    test('counts date rows in the index so AutoScrollTag still matches', () {
      final messages = [
        _msg(id: 'oldest', sentAt: 1),
        _msg(
          id: 'date',
          sentAt: 2,
          type: IsmChatCustomMessageType.date,
        ),
        _msg(id: 'newest', sentAt: 3),
      ];

      expect(
        IsmChatPageViewModel.reversedScrollIndexForMessageId(
          messages,
          messageId: 'oldest',
        ),
        2,
      );
    });

    test('stays correct after a new message is appended (stale-map case)', () {
      final messages = [
        _msg(id: 'quoted', sentAt: 1),
        _msg(id: 'reply', sentAt: 2),
        _msg(id: 'later', sentAt: 3),
      ];

      expect(
        IsmChatPageViewModel.reversedScrollIndexForMessageId(
          messages,
          messageId: 'quoted',
        ),
        2,
      );
    });

    test('returns null for empty or missing ids', () {
      expect(
        IsmChatPageViewModel.reversedScrollIndexForMessageId(
          [_msg(id: 'a', sentAt: 1)],
          messageId: '',
        ),
        isNull,
      );
      expect(
        IsmChatPageViewModel.reversedScrollIndexForMessageId(
          [_msg(id: 'a', sentAt: 1)],
          messageId: 'missing',
        ),
        isNull,
      );
    });
  });
}
