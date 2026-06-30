import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/src/models/chat_conversation_model.dart';
import 'package:isometrik_chat_flutter/src/models/chat_message_model.dart';

/// Identifies which confirmation UI the SDK is showing (block, delete, clear, etc.).
enum IsmChatConfirmationType {
  /// Confirm blocking the opponent.
  confirmBlock,

  /// Confirm unblocking.
  confirmUnblock,

  /// User blocked opponent; composer tap offers unblock.
  blockedByYouPromptUnblock,

  /// Opponent blocked me; info-only.
  cannotBlockOpponent,

  /// Block action while opponent already blocked me.
  cannotBlockWhenTheyBlockedMe,

  /// Delete own message: delete for everyone + delete for me.
  deleteMessageOwn,

  /// Delete opponent message for me only.
  deleteMessageOther,

  /// Multi-select delete (own messages).
  deleteMultipleOwn,

  /// Multi-select delete (other / already deleted for everyone).
  deleteMultipleOther,

  /// Clear all messages in a conversation (chat header / list / info).
  clearChatMessages,

  /// Delete a group conversation.
  deleteGroup,

  /// Delete a 1-1 (or non-group) chat from list or conversation info.
  deleteChat,

  /// User tapped a reaction they already added to a message.
  alreadyAddedReaction,
}

/// Action ids map to the same SDK handlers as default alert dialog buttons.
enum IsmChatConfirmationActionId {
  block,
  unblock,
  deleteForEveryone,
  deleteForMe,
  clearChat,
  deleteGroup,
  deleteChat,
  dismiss,
}

/// One confirm/cancel control; [onPressed] runs the same logic as the default dialog.
class IsmChatConfirmationAction {
  const IsmChatConfirmationAction({
    required this.id,
    required this.label,
    required this.onPressed,
  });

  final IsmChatConfirmationActionId id;
  final String label;
  final VoidCallback onPressed;
}

/// Payload passed to [ChatConfirmationPresenter] for confirmations.
class IsmChatConfirmationRequest {
  const IsmChatConfirmationRequest({
    required this.type,
    required this.title,
    required this.actions,
    this.cancelLabel,
    this.onCancel,
    this.conversation,
    this.message,
    this.messages,
    this.messageCount,
  });

  final IsmChatConfirmationType type;
  final String title;
  final List<IsmChatConfirmationAction> actions;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final IsmChatConversationModel? conversation;
  final IsmChatMessageModel? message;
  final List<IsmChatMessageModel>? messages;
  final int? messageCount;

  IsmChatConfirmationAction? actionById(IsmChatConfirmationActionId id) {
    for (final action in actions) {
      if (action.id == id) return action;
    }
    return null;
  }
}
