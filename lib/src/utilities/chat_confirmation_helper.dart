import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Presents block/delete/clear/delete-chat confirmations via
/// [IsmChatPageProperties.chatConfirmationPresenter] or default dialog.
///
/// When [IsmChatPageProperties.chatConfirmationPresenter] is set, it is invoked
/// first. Return `true` from the presenter to skip the default dialog;
/// return `false` to show the SDK default UI for that request.
class IsmChatConfirmationHelper {
  IsmChatConfirmationHelper._();

  static Future<void> present(IsmChatConfirmationRequest request) async {
    final presenter =
        IsmChatProperties.chatPageProperties.chatConfirmationPresenter;
    final context =
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context;
    if (presenter != null) {
      final handled = await presenter(context, request);
      if (handled) {
        return;
      }
    }

    await presentDefault(request);
  }

  /// SDK default [IsmChatAlertDialogBox]. Used when no presenter is set, or
  /// when the presenter returns `false` for a request.
  static Future<void> presentDefault(IsmChatConfirmationRequest request) async {
    final labels = request.actions.map((a) => a.label).toList();
    final callbacks = request.actions.map((a) => a.onPressed).toList();
    await IsmChatContextWidget.showDialogContext(
      content: IsmChatAlertDialogBox(
        title: request.title,
        content: request.content ??
            (request.body == null ? null : Text(request.body!)),
        actionLabels: labels.isEmpty ? null : labels,
        callbackActions: callbacks.isEmpty ? null : callbacks,
        cancelLabel: request.cancelLabel ?? IsmChatStrings.cancel,
        onCancel: request.onCancel,
      ),
    );
  }

  /// Server clear is skipped when the last message is "you were removed" from a group.
  static bool shouldClearMessagesFromServer(
          IsmChatConversationModel? conversation) =>
      !(conversation?.lastMessageDetails?.customType ==
              IsmChatCustomMessageType.removeMember &&
          conversation?.lastMessageDetails?.userId ==
              IsmChatConfig.communicationConfig.userConfig.userId);

  /// Duplicate reaction (API 404). Uses [chatConfirmationPresenter] when set.
  static Future<void> presentAlreadyAddedReaction({
    IsmChatMessageModel? message,
  }) async {
    await present(
      IsmChatConfirmationRequest(
        type: IsmChatConfirmationType.alreadyAddedReaction,
        title: IsmChatStrings.alreadyAddedReaction,
        message: message,
        cancelLabel: IsmChatStrings.okay,
        actions: const [],
      ),
    );
  }
}
