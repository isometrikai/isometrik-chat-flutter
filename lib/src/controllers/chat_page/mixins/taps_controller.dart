part of '../chat_page_controller.dart';

mixin IsmChatTapsController on GetxController {
  IsmChatPageController get _controller =>
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  void onMessageTap(
      {required BuildContext context,
      required IsmChatMessageModel message}) async {
    _controller.closeOverlay();
    final response =
        await IsmChatProperties.chatPageProperties.onMessageTap?.call(
      context,
      message,
      _controller.conversation!,
    );

    if (response?.$2 ?? true) {
      if (message.messageType == IsmChatMessageType.reply) {
        if ([
          IsmChatCustomMessageType.image,
          IsmChatCustomMessageType.video,
          IsmChatCustomMessageType.file,
          if (!IsmChatResponsive.isWeb(Get.context!))
            IsmChatCustomMessageType.contact,
        ].contains(
          message.metaData?.replyMessage?.parentMessageMessageType,
        )) {
          _controller.tapForMediaPreviewWithMetaData(message);
        }
      } else if ([
        IsmChatCustomMessageType.image,
        IsmChatCustomMessageType.video,
        IsmChatCustomMessageType.file,
        if (!IsmChatResponsive.isWeb(Get.context!))
          IsmChatCustomMessageType.contact,
      ].contains(message.customType)) {
        _controller.tapForMediaPreview(message);
      }
      if (message.sentByMe == false) {
        unawaited(
          _controller.updateMessage(
            messageId: message.messageId ?? '',
            conversationId: message.conversationId ?? '',
            isOpponentMessage: true,
            metaData: response?.$1 != null
                ? IsmChatMetaData.fromMap(
                    response?.$1 ?? {},
                  )
                : null,
          ),
        );
      }
    }
  }
}
