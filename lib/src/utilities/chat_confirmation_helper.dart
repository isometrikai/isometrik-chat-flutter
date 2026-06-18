import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Presents block/delete/clear/delete-chat confirmations via
/// [IsmChatPageProperties.chatConfirmationPresenter] or default dialog.
class IsmChatConfirmationHelper {
  IsmChatConfirmationHelper._();

  static Future<void> present(IsmChatConfirmationRequest request) async {
    final presenter =
        IsmChatProperties.chatPageProperties.chatConfirmationPresenter;
    final context =
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context;
    if (presenter != null) {
      final handled = await presenter(context, request);
      if (handled == true) {
        return;
      }
      // null / false → use default SDK dialog below
    }

    await IsmChatContextWidget.showThemedAlertDialog(
      title: request.title,
      actionLabels:
          request.actions.isEmpty ? null : request.actions.map((a) => a.label).toList(),
      callbackActions: request.actions.isEmpty
          ? null
          : request.actions.map((a) => a.onPressed).toList(),
      cancelLabel: request.cancelLabel ?? IsmChatStrings.cancel,
      onCancel: request.onCancel,
    );
  }

  /// Server clear is skipped when the last message is "you were removed" from a group.
  static bool shouldClearMessagesFromServer(IsmChatConversationModel? conversation) =>
      !(conversation?.lastMessageDetails?.customType ==
              IsmChatCustomMessageType.removeMember &&
          conversation?.lastMessageDetails?.userId ==
              IsmChatConfig.communicationConfig.userConfig.userId);
}
