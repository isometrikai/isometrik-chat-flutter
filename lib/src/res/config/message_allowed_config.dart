import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Controls whether outbound messages may be sent, and how blocked ones behave.
///
/// **Reuse guide (Hookup / dating safety filter):**
/// 1. Put on-device checks in [onBeforeSendMessage] (regex keywords first;
///    optional ML later per `local-message-detection-flutter-guide.md`).
/// 2. Return [IsmChatMessageSendDecision.keepLocal] for phishing so the user
///    still sees their bubble, but the SDK never calls the send API.
/// 3. Use [onMessageSendBlocked] to log / analytics the failure in the host app.
/// 4. Keep using legacy [isMessgeAllowed] only when you need a simple bool gate
///    (`false` = [IsmChatMessageSendDecision.block]). Prefer [onBeforeSendMessage]
///    for new integrations — it wins when both are set.
class MessageAllowedConfig {
  MessageAllowedConfig({
    this.isShowTextfiledConfig,
    this.isMessgeAllowed,
    this.onBeforeSendMessage,
    this.onMessageSendBlocked,
    this.messageText,
  });

  /// Legacy allow-check: return `false` to block (no local bubble).
  ///
  /// Prefer [onBeforeSendMessage] when you need keep-local / reasons.
  ConditionConversationCustomeTypeCallback? isMessgeAllowed;

  /// Preferred pre-send gate (allow / block / keepLocal + optional reason).
  IsmChatBeforeSendMessageCallback? onBeforeSendMessage;

  /// Host logging hook when send is blocked or kept local-only.
  IsmChatMessageSendBlockedCallback? onMessageSendBlocked;

  IsShowTextfiledConfig? isShowTextfiledConfig;
  StringConversationCallback? messageText;

  /// Serializes overlapping [resolveOutboundSendDecision] calls on this config.
  ///
  /// Host filters often close over mutable rate-limit / keyword state. Dart is
  /// single-threaded, but two sends can still interleave across `await`s
  /// (double-tap, text + attachment). Reuse this chain rather than adding a
  /// second lock. Host callbacks must not re-enter this method (would deadlock).
  Future<void> _outboundDecisionChain = Future<void>.value();

  /// Resolves the outbound send decision for the given composer content.
  ///
  /// Order: [onBeforeSendMessage] → legacy [isMessgeAllowed] → allow.
  /// Overlapping calls on this instance run FIFO so each send gets a decision
  /// computed against a consistent callback snapshot.
  Future<IsmChatMessageSendDecision> resolveOutboundSendDecision({
    required BuildContext context,
    required IsmChatConversationModel? conversation,
    required IsmChatCustomMessageType customType,
    String? messageText,
  }) async {
    final previous = _outboundDecisionChain;
    final gate = Completer<void>();
    _outboundDecisionChain = gate.future;
    await previous;
    try {
      return await _evaluateOutboundSendDecision(
        context: context,
        conversation: conversation,
        customType: customType,
        messageText: messageText,
      );
    } finally {
      gate.complete();
    }
  }

  /// Evaluates one send against callbacks captured at the start of this turn.
  ///
  /// Snapshot the function refs locally — do not re-read [onBeforeSendMessage]
  /// / [isMessgeAllowed] after an await, or a host swapping those fields mid-
  /// flight can mix "preferred hook" of one generation with "legacy bool" of
  /// another (allow on one path, block on the next for the same text).
  Future<IsmChatMessageSendDecision> _evaluateOutboundSendDecision({
    required BuildContext context,
    required IsmChatConversationModel? conversation,
    required IsmChatCustomMessageType customType,
    String? messageText,
  }) async {
    final beforeSend = onBeforeSendMessage;
    if (beforeSend != null) {
      return await beforeSend(
            context,
            conversation,
            customType,
            messageText,
          ) ??
          IsmChatMessageSendDecision.allow();
    }

    final legacyAllowed = isMessgeAllowed;
    final allowed = await legacyAllowed?.call(
          context,
          conversation,
          customType,
          messageText,
        ) ??
        true;
    if (allowed == false) {
      return IsmChatMessageSendDecision.block();
    }
    return IsmChatMessageSendDecision.allow();
  }

  /// Convenience for media / contact / location / forward paths where
  /// [IsmChatMessageSendDecision.keepLocal] is not supported — returns whether
  /// the normal send may proceed, and logs block/keepLocal via
  /// [notifyMessageSendBlocked].
  Future<bool> shouldAllowOutboundSend({
    required BuildContext context,
    required IsmChatConversationModel? conversation,
    required IsmChatCustomMessageType customType,
    String? messageText,
  }) async {
    final decision = await resolveOutboundSendDecision(
      context: context,
      conversation: conversation,
      customType: customType,
      messageText: messageText,
    );
    if (decision.shouldSend) {
      return true;
    }
    // keepLocal is text-only; for attachments treat as block + still log.
    notifyMessageSendBlocked(
      decision: decision.shouldKeepLocal
          ? IsmChatMessageSendDecision.block(reason: decision.reason)
          : decision,
      body: messageText,
      conversation: conversation,
      customType: customType,
    );
    return false;
  }

  /// Notifies the host that a send was blocked or kept local-only.
  ///
  /// Safe no-op when [onMessageSendBlocked] is null.
  void notifyMessageSendBlocked({
    required IsmChatMessageSendDecision decision,
    IsmChatMessageModel? message,
    String? body,
    IsmChatConversationModel? conversation,
    IsmChatCustomMessageType? customType,
  }) {
    if (onMessageSendBlocked == null) return;
    if (decision.shouldSend) return;

    final blockedMessage = message ??
        IsmChatMessageModel(
          body: body ?? '',
          conversationId: conversation?.conversationId,
          customType: customType,
          sentAt: DateTime.now().millisecondsSinceEpoch,
          sentByMe: true,
          messageId: '',
          isInvalidMessage: true,
          metaData: IsmChatMetaData(
            customMetaData: {
              'localSendBlocked': true,
              if (decision.reason != null)
                'localSendBlockReason': decision.reason,
            },
          ),
        );
    onMessageSendBlocked!(blockedMessage, decision);
  }
}

class IsShowTextfiledConfig {
  IsShowTextfiledConfig({
    required this.isShowMessageAllowed,
    this.shwoMessage,
    this.messageWidget,
  });
  ConditionConversationCallback isShowMessageAllowed;

  StringConversationCallback? shwoMessage;

  WidgetConversationCallback? messageWidget;
}

/// Convenience resolver when [MessageAllowedConfig] may be null → allow.
extension MessageAllowedConfigResolve on MessageAllowedConfig? {
  Future<IsmChatMessageSendDecision> resolveOutboundSendDecision({
    required BuildContext context,
    required IsmChatConversationModel? conversation,
    required IsmChatCustomMessageType customType,
    String? messageText,
  }) async {
    // Snapshot `this` before any await. Properties.messageAllowedConfig can be
    // swapped while a send is in flight; keep using the instance that started
    // this decision so allow/block cannot flip to a different config mid-call.
    final config = this;
    if (config == null) {
      return IsmChatMessageSendDecision.allow();
    }
    return config.resolveOutboundSendDecision(
      context: context,
      conversation: conversation,
      customType: customType,
      messageText: messageText,
    );
  }

  Future<bool> shouldAllowOutboundSend({
    required BuildContext context,
    required IsmChatConversationModel? conversation,
    required IsmChatCustomMessageType customType,
    String? messageText,
  }) async {
    final config = this;
    if (config == null) {
      return true;
    }
    return config.shouldAllowOutboundSend(
      context: context,
      conversation: conversation,
      customType: customType,
      messageText: messageText,
    );
  }
}
