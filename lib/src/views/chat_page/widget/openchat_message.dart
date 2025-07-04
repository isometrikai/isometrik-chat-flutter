import 'dart:async';

import 'package:custom_will_pop_scope/custom_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatOpenChatMessagePage extends StatelessWidget {
  const IsmChatOpenChatMessagePage({super.key});

  Future<bool> _back({
    required BuildContext context,
    required IsmChatPageController controller,
  }) async {
    final controller = IsmChatUtility.chatPageController;
    final conversationController = IsmChatUtility.conversationController;
    if (IsmChatResponsive.isWeb(context)) {
      controller.isBroadcast = false;
      conversationController.currentConversation = null;
      conversationController.currentConversationId = '';
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.none;
      await Get.delete<IsmChatPageController>(
          force: true, tag: IsmChat.i.chatPageTag);
    } else {
      IsmChatRoute.goBack();
    }
    unawaited(conversationController.leaveObserver(
      conversationId: controller.conversation?.conversationId ?? '',
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => CustomWillPopScope(
          onWillPop: () async => await _back(
            context: context,
            controller: controller,
          ),
          child: Scaffold(
            backgroundColor:
                IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                    IsmChatColors.whiteColor,
            appBar: IsmChatAppBar(
              leadingWidth: IsmChatDimens.thirty,
              leading: IsmChatTapHandler(
                onTap: () => _back(context: context, controller: controller),
                child: Icon(
                  IsmChatResponsive.isWeb(context)
                      ? Icons.close_rounded
                      : Icons.arrow_back_rounded,
                  color:
                      IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                          IsmChatColors.whiteColor,
                ),
              ),
              centerTitle: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IsmChatImage.profile(
                    controller.conversation?.profileUrl ?? '',
                    name: controller.conversation?.chatName,
                    dimensions: IsmChatDimens.forty,
                    isNetworkImage:
                        (controller.conversation?.profileUrl ?? '').isValidUrl,
                  ),
                  IsmChatDimens.boxWidth8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.conversation?.chatName}',
                        style: IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.titleStyle ??
                            IsmChatStyles.w600White16,
                      ),
                      if (controller.messages.isNotEmpty)
                        Text(
                          '${controller.conversation?.membersCount} ${IsmChatStrings.participants.toUpperCase()}',
                          style: IsmChatConfig.chatTheme.chatPageHeaderTheme
                                  ?.subtileStyle ??
                              IsmChatStyles.w400White12,
                        )
                    ],
                  ),
                ],
              ),
              backgroundColor: IsmChatConfig
                      .chatTheme.chatPageHeaderTheme?.backgroundColor ??
                  IsmChatConfig.chatTheme.primaryColor,
              action: [
                IconButton(
                  onPressed: () async {
                    if (IsmChatResponsive.isWeb(context)) {
                      await IsmChatContextWidget.showDialogContext(
                        content: IsmChatPageDailog(
                          child: IsmChatObserverUsersView(
                            conversationId:
                                controller.conversation?.conversationId ?? '',
                          ),
                        ),
                      );
                    } else {
                      await IsmChatRoute.goToRoute(IsmChatObserverUsersView(
                        conversationId:
                            controller.conversation?.conversationId ?? '',
                      ));
                    }
                  },
                  icon: Icon(
                    Icons.person_search_outlined,
                    size: IsmChatDimens.thirty,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatColors.whiteColor,
                  ),
                )
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                      controller: controller.messagesScrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      reverse: true,
                      padding: IsmChatDimens.edgeInsets4_8,
                      itemCount: controller.messages.length,
                      itemBuilder: (_, index) => IsmChatMessage(
                        index,
                        controller.messages[index],
                        isIgnorTap: false,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: IsmChatConfig
                      .chatTheme.chatPageTheme?.textFiledTheme?.textfieldInsets,
                  decoration: IsmChatConfig
                      .chatTheme.chatPageTheme?.textFiledTheme?.decoration,
                  child: const SafeArea(
                    child: IsmChatMessageField(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
