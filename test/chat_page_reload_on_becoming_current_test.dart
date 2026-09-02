import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

void main() {
  group('IsmChatPageView.shouldReloadOnBecomingCurrent', () {
    test('does not reload when a popup closed over the same chat', () {
      // Reaction / attachment sheets and dialogs also make the chat route
      // non-current; reloading there resets the reader's scroll position.
      expect(
        IsmChatPageView.shouldReloadOnBecomingCurrent(
          openedConversationId: 'chat-1',
          currentConversationId: 'chat-1',
          rebindConversationId: null,
        ),
        isFalse,
      );
    });

    test('reloads when a stacked chat page overwrote the shared controller',
        () {
      expect(
        IsmChatPageView.shouldReloadOnBecomingCurrent(
          openedConversationId: 'chat-1',
          currentConversationId: 'chat-2',
          rebindConversationId: null,
        ),
        isTrue,
      );
    });

    test('reloads when this route was rebound to another chat', () {
      expect(
        IsmChatPageView.shouldReloadOnBecomingCurrent(
          openedConversationId: 'chat-2',
          currentConversationId: 'chat-2',
          rebindConversationId: 'chat-2',
        ),
        isTrue,
      );
    });

    test('does nothing before this route resolved its conversation', () {
      expect(
        IsmChatPageView.shouldReloadOnBecomingCurrent(
          openedConversationId: '',
          currentConversationId: 'chat-1',
          rebindConversationId: null,
        ),
        isFalse,
      );
    });
  });

  group('IsmChatPageView.shouldAttachMessagesScrollController', () {
    test('stays attached when a popup covers the chat', () {
      expect(
        IsmChatPageView.shouldAttachMessagesScrollController(
          isCurrentRoute: false,
          secondaryAnimationStatus: AnimationStatus.dismissed,
        ),
        isTrue,
      );
    });

    test('detaches when a full page is stacked on the chat', () {
      expect(
        IsmChatPageView.shouldAttachMessagesScrollController(
          isCurrentRoute: false,
          secondaryAnimationStatus: AnimationStatus.completed,
        ),
        isFalse,
      );
    });

    test('attaches when this chat is the current route', () {
      expect(
        IsmChatPageView.shouldAttachMessagesScrollController(
          isCurrentRoute: true,
          secondaryAnimationStatus: AnimationStatus.dismissed,
        ),
        isTrue,
      );
    });
  });
}
