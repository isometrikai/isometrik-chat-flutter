import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatSearchMessgae extends StatelessWidget {
  const IsmChatSearchMessgae({super.key});

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        initState: (_) {
          final controller = IsmChatUtility.chatPageController;
          controller.searchMessages.clear();
          controller.textEditingController.clear();
          controller.canCallCurrentApi = false;
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor:
              IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                  IsmChatColors.whiteColor,
          appBar: IsmChatAppBar(
            height: IsmChatDimens.fiftyFive,
            onBack: !IsmChatResponsive.isWeb(context)
                ? null
                : () {
                    Get.find<IsmChatConversationsController>(
                            tag: IsmChat.i.chatListPageTag)
                        .isRenderChatPageaScreen = IsRenderChatPageScreen.none;
                  },
            backIcon: Icons.close_rounded,
            title: IsmChatInputField(
              fillColor: IsmChatConfig.chatTheme.primaryColor,
              autofocus: true,
              hint: 'Search message..',
              hintStyle: IsmChatStyles.w600White16,
              cursorColor: IsmChatColors.whiteColor,
              style: IsmChatStyles.w600White16,
              controller: controller.textEditingController,
              onChanged: (value) {
                controller.ismChatDebounce.run(
                  () {
                    controller.searchedMessages(value);
                  },
                );
              },
            ),
          ),
          body: controller.searchMessages.isEmpty &&
                  controller.textEditingController.text.isNotEmpty
              ? Center(
                  child: Text(
                    IsmChatStrings.noMessageFound,
                    style: IsmChatStyles.w600Black20,
                  ),
                )
              : controller.textEditingController.text.isEmpty
                  ? Center(
                      child: SizedBox(
                        width: IsmChatDimens.percentWidth(.7),
                        child: Text(
                          IsmChatStrings.noSearch,
                          style: IsmChatStyles.w600Black20,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SafeArea(
                      child: SizedBox(
                        height: IsmChatDimens.percentHeight(1),
                        width: IsmChatDimens.percentWidth(1),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            controller:
                                controller.searchMessageScrollController,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,
                            padding: IsmChatDimens.edgeInsets4_8,
                            addAutomaticKeepAlives: true,
                            itemCount: controller.searchMessages.length,
                            itemBuilder: (_, index) => IsmChatMessage(
                              index,
                              controller.searchMessages[index],
                              isFromSearchMessage: true,
                              isIgnorTap: true,
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      );
}
