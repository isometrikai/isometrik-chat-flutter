import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatSearchMessgae extends StatelessWidget {
  const IsmChatSearchMessgae({super.key});

  static const String route = IsmPageRoutes.searchMessage;

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        initState: (_) {
          final controller = Get.find<IsmChatPageController>();
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
            onBack: !IsmChatResponsive.isWeb(context)
                ? null
                : () {
                    Get.find<IsmChatConversationsController>()
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
                        height: Get.height,
                        width: Get.width,
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
