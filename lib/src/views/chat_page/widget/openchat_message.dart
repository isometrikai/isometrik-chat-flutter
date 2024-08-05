import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/src/controllers/controllers.dart';
import 'package:isometrik_flutter_chat/src/res/res.dart';
import 'package:isometrik_flutter_chat/src/utilities/utilities.dart';
import 'package:isometrik_flutter_chat/src/views/views.dart';
import 'package:isometrik_flutter_chat/src/widgets/widgets.dart';

class IsmChatOpenChatMessagePage extends StatelessWidget {
  const IsmChatOpenChatMessagePage({super.key});

  static const String route = IsmPageRoutes.openChatMessagePage;

  void _back(BuildContext context, IsmChatPageController controller) async {
    var controller = Get.find<IsmChatPageController>();
    final conversationController = Get.find<IsmChatConversationsController>();
    if (IsmChatResponsive.isWeb(context)) {
      controller.isBroadcast = false;
      conversationController.currentConversation = null;
      conversationController.currentConversationId = '';
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.none;
      await Get.delete<IsmChatPageController>(force: true);
    } else {
      Get.back();
    }
    unawaited(
      conversationController.leaveObserver(
          conversationId: controller.conversation?.conversationId ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            _back(context, controller);
          },
          child: Scaffold(
            backgroundColor:
                IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                    IsmChatColors.whiteColor,
            appBar: IsmChatAppBar(
              leadingWidth: IsmChatDimens.thirty,
              leading: IsmChatTapHandler(
                onTap: () => _back(context, controller),
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
                      await Get.dialog(IsmChatPageDailog(
                        child: IsmChatObserverUsersView(
                          conversationId:
                              controller.conversation?.conversationId ?? '',
                        ),
                      ));
                    } else {
                      IsmChatRouteManagement.goToObserverView(
                          controller.conversation?.conversationId ?? '');
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
                  padding: IsmChatConfig.chatTheme.chatPageTheme
                      ?.textFiledThemData?.textfieldInsets,
                  decoration: IsmChatConfig
                      .chatTheme.chatPageTheme?.textFiledThemData?.decoration,
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
