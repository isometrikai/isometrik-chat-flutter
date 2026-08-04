import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Outcome of a pre-send allow-check (phishing / safety / host policy).
///
/// **Reuse (Hookup / dating apps):** run an on-device filter (e.g. a local
/// regex/keyword `LocalMessageFilter`) inside
/// `MessageAllowedConfig.onBeforeSendMessage` and return:
/// - [IsmChatMessageSendDecision.allow] — normal send (API)
/// - [IsmChatMessageSendDecision.block] — do not show or send; input stays
/// - [IsmChatMessageSendDecision.keepLocal] — show in chat + persist locally,
///   never hit the send API; UI uses [IsmChatMessageModel.isInvalidMessage]
///
/// Optional `reason` is forwarded to `MessageAllowedConfig.onMessageSendBlocked`
/// for analytics / logging in the host app.
enum IsmChatMessageSendAction {
  /// Continue with the normal send pipeline (local pending → API).
  allow,

  /// Abort send entirely; message is not added to the chat list.
  block,

  /// Add message to the local chat + main DB only; skip API / pending retry.
  keepLocal,
}

/// Result returned by [MessageAllowedConfig.onBeforeSendMessage].
class IsmChatMessageSendDecision {
  const IsmChatMessageSendDecision._({
    required this.action,
    this.reason,
  });

  /// Allow the message to be sent via the normal API path.
  factory IsmChatMessageSendDecision.allow({String? reason}) =>
      IsmChatMessageSendDecision._(
        action: IsmChatMessageSendAction.allow,
        reason: reason,
      );

  /// Block send; do not keep a local bubble.
  factory IsmChatMessageSendDecision.block({String? reason}) =>
      IsmChatMessageSendDecision._(
        action: IsmChatMessageSendAction.block,
        reason: reason,
      );

  /// Keep the message in the local chat UI/DB but never send it on the API.
  ///
  /// Currently fully supported for text/reply sends. Other attachment types
  /// treat this like [IsmChatMessageSendDecision.block] (no send) but still fire
  /// `MessageAllowedConfig.onMessageSendBlocked` when configured.
  factory IsmChatMessageSendDecision.keepLocal({String? reason}) =>
      IsmChatMessageSendDecision._(
        action: IsmChatMessageSendAction.keepLocal,
        reason: reason,
      );

  final IsmChatMessageSendAction action;

  /// Optional host reason (e.g. `phishing_phone`, `scam_phrase`) for logging.
  final String? reason;

  bool get shouldSend => action == IsmChatMessageSendAction.allow;

  bool get shouldBlock => action == IsmChatMessageSendAction.block;

  bool get shouldKeepLocal => action == IsmChatMessageSendAction.keepLocal;
}

/// Preferred pre-send gate. Prefer this over legacy [MessageAllowedConfig.isMessgeAllowed]
/// when you need [IsmChatMessageSendDecision.keepLocal].
typedef IsmChatBeforeSendMessageCallback = Future<IsmChatMessageSendDecision?>
    Function(
  BuildContext context,
  IsmChatConversationModel? conversation,
  IsmChatCustomMessageType customType,
  String? messageText,
);

/// Called when a send is blocked or kept local-only (for host analytics / logging).
///
/// For [IsmChatMessageSendAction.keepLocal], [message] is the local bubble that
/// was persisted. For [IsmChatMessageSendAction.block], [message] is a lightweight
/// model built from the composer text (not added to the chat list).
typedef IsmChatMessageSendBlockedCallback = void Function(
  IsmChatMessageModel message,
  IsmChatMessageSendDecision decision,
);
