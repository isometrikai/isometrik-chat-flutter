import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatSearchConversation extends StatelessWidget {
  const IsmChatSearchConversation({super.key});

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
          tag: IsmChat.i.chatListPageTag,
          builder: (controller) => IsmChatInputField(
                isShowBorderColor: true,
                contentPadding: IsmChatDimens.edgeInsets20,
                autofocus: false,
                borderRadius: IsmChatDimens.fifteen,
                cursorColor: IsmChatColors.blackColor,
                fillColor: IsmChatColors.whiteColor,
                controller: controller.searchConversationTEC,
                style: IsmChatStyles.w400Black18
                    .copyWith(fontSize: IsmChatDimens.twenty),
                borderColor: IsmChatConfig.chatTheme.borderColor ??
                    IsmChatColors.greyColor.applyIsmOpacity(.5),
                hint: IsmChatStrings.searchChat,
                hintStyle: IsmChatStyles.w400Black18
                    .copyWith(fontSize: IsmChatDimens.twenty),
                onChanged: (value) async {
                  controller.debounce.run(() async {
                    switch (value.trim().isNotEmpty) {
                      case true:
                        await controller.getChatConversations(
                          searchTag: value,
                        );
                        break;
                      default:
                        await controller.getConversationsFromDB();
                    }
                  });
                  controller.update();
                },
                suffixIcon: controller.searchConversationTEC.text.isNotEmpty
                    ? IconButton(
                        highlightColor: IsmChatColors.transparent,
                        disabledColor: IsmChatColors.transparent,
                        hoverColor: IsmChatColors.transparent,
                        splashColor: IsmChatColors.transparent,
                        focusColor: IsmChatColors.transparent,
                        onPressed: () {
                          controller.searchConversationTEC.clear();
                          controller.getConversationsFromDB();
                        },
                        icon: const Icon(
                          Icons.close_outlined,
                          color: IsmChatColors.whiteColor,
                        ),
                      )
                    : null,
              ));
}
