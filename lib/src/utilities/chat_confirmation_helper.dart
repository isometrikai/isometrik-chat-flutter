import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Presents block/delete/clear/delete-chat confirmations via
/// [IsmChatPageProperties.chatConfirmationPresenter] or default dialog.
///
/// When [IsmChatPageProperties.chatConfirmationPresenter] is set, the SDK never
/// shows its default dialog after the presenter completes. Call [presentDefault]
/// from the presenter if a specific request should use the SDK UI.
class IsmChatConfirmationHelper {
  IsmChatConfirmationHelper._();

  static Future<void> present(IsmChatConfirmationRequest request) async {
    final presenter =
        IsmChatProperties.chatPageProperties.chatConfirmationPresenter;
    final context =
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context;
    if (presenter != null) {
      await presenter(context, request);
      return;
    }

    await presentDefault(request);
  }

  /// SDK default [IsmChatAlertDialogBox]. Use from a custom presenter when needed.
  static Future<void> presentDefault(IsmChatConfirmationRequest request) async {
    final labels = request.actions.map((a) => a.label).toList();
    final callbacks = request.actions.map((a) => a.onPressed).toList();
    await IsmChatContextWidget.showDialogContext(
      content: IsmChatAlertDialogBox(
        title: request.title,
        actionLabels: labels.isEmpty ? null : labels,
        callbackActions: callbacks.isEmpty ? null : callbacks,
        cancelLabel: request.cancelLabel ?? IsmChatStrings.cancel,
        onCancel: request.onCancel,
      ),
    );
  }

  /// Server clear is skipped when the last message is "you were removed" from a group.
  static bool shouldClearMessagesFromServer(IsmChatConversationModel? conversation) =>
      !(conversation?.lastMessageDetails?.customType ==
              IsmChatCustomMessageType.removeMember &&
          conversation?.lastMessageDetails?.userId ==
              IsmChatConfig.communicationConfig.userConfig.userId);
}
