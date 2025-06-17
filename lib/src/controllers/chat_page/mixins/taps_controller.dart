part of '../chat_page_controller.dart';

mixin IsmChatTapsController on GetxController {
  IsmChatPageController get _controller => IsmChatUtility.chatPageController;

  void onMessageTap({
    required BuildContext context,
    required IsmChatMessageModel message,
  }) async {
    _controller.closeOverlay();
    final response =
        await IsmChatProperties.chatPageProperties.onMessageTap?.call(
      context,
      message,
      _controller.conversation,
    );
    if (response?.shouldGoToMediaPreview ?? true) {
      if (message.messageType != IsmChatMessageType.reply) {
        if ([
          IsmChatCustomMessageType.image,
          IsmChatCustomMessageType.video,
          IsmChatCustomMessageType.file,
          if (!IsmChatResponsive.isWeb(
              IsmChatConfig.kNavigatorKey.currentContext ??
                  IsmChatConfig.context))
            IsmChatCustomMessageType.contact,
        ].contains(
          message.customType,
        )) {
          _controller.tapForMediaPreview(message);
        } else if (message.customType == IsmChatCustomMessageType.location) {
          var url = '';
          if (message.body.isValidUrl) {
            url = message.body;
          } else {
            url = message.attachments?.first.mediaUrl ?? '';
          }
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    }
    if (response?.shouldUpdateMessage ?? true) {
      if (message.sentByMe == false) {
        unawaited(
          _controller.updateMessage(
            messageId: message.messageId ?? '',
            conversationId: message.conversationId ?? '',
            isOpponentMessage: true,
            metaData: response?.metaData != null
                ? IsmChatMetaData.fromMap(
                    response?.metaData ?? {},
                  )
                : null,
          ),
        );
      }
    }
  }
}
