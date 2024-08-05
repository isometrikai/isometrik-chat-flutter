import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/src/controllers/controllers.dart';
import 'package:isometrik_flutter_chat/src/res/res.dart';
import 'package:isometrik_flutter_chat/src/utilities/utilities.dart';
import 'package:isometrik_flutter_chat/src/views/views.dart';
import 'package:isometrik_flutter_chat/src/widgets/widgets.dart';

class IsmChatBoradcastMessagePage extends StatelessWidget {
  const IsmChatBoradcastMessagePage({super.key});

  static const String route = IsmPageRoutes.boradCastMessagePage;

  Future<bool> _back(
    BuildContext context,
  ) async {
    var controller = Get.find<IsmChatPageController>();
    var conversationController = Get.find<IsmChatConversationsController>();

    if (IsmChatResponsive.isWeb(context)) {
      var controller = Get.find<IsmChatPageController>();
      controller.isBroadcast = false;
      conversationController.currentConversation = null;
      conversationController.currentConversationId = '';
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.none;
      await Get.delete<IsmChatPageController>(force: true);
    } else {
      if (controller.messages.isNotEmpty) {
        Get.back();
      }
      Get.back();
    }
    if (controller.messages.isNotEmpty) {
      unawaited(conversationController.getChatConversations());
      conversationController.selectedUserList.clear();
      conversationController.forwardedList.clear();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (!GetPlatform.isAndroid) {
            return false;
          }
          return await _back(context);
        },
        child: GetPlatform.isIOS
            ? GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 50) {
                    _back(context);
                  }
                },
                child: _BroadCastMessage(
                  onBackTap: () => _back(context),
                ),
              )
            : _BroadCastMessage(
                onBackTap: () => _back(context),
              ),
      );
}

class _BroadCastMessage extends StatelessWidget {
  const _BroadCastMessage({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => Scaffold(
          backgroundColor:
              IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                  IsmChatColors.whiteColor,
          appBar: IsmChatAppBar(
            leading: IsmChatTapHandler(
              onTap: onBackTap,
              child: Padding(
                padding: IsmChatDimens.edgeInsetsLeft10,
                child: Icon(
                  IsmChatResponsive.isWeb(context)
                      ? Icons.close_rounded
                      : Icons.arrow_back_rounded,
                  color:
                      IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                          IsmChatColors.whiteColor,
                ),
              ),
            ),
            centerTitle: false,
            leadingWidth: IsmChatDimens.forty,
            title: Row(
              children: [
                Container(
                  height: IsmChatDimens.forty,
                  width: IsmChatDimens.forty,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: IsmChatColors.whiteColor,
                  ),
                  child: const Icon(Icons.campaign_rounded),
                ),
                IsmChatDimens.boxWidth12,
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.conversation?.members?.length} Recipients Selected',
                        style: IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.titleStyle ??
                            IsmChatStyles.w600White16,
                      ),
                      Text(
                        controller.conversation?.members
                                ?.map((e) => e.userName)
                                .join(',') ??
                            '',
                        style: IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.subtileStyle ??
                            IsmChatStyles.w400White12,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor:
                IsmChatConfig.chatTheme.chatPageHeaderTheme?.backgroundColor ??
                    IsmChatConfig.chatTheme.primaryColor,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: controller.isMessagesLoading
                    ? const IsmChatLoadingDialog()
                    : controller.messages.isNotEmpty
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              reverse: true,
                              padding: IsmChatDimens.edgeInsets4_8,
                              itemCount: controller.messages.length,
                              itemBuilder: (_, index) => IsmChatMessage(
                                index,
                                controller.messages[index],
                                isIgnorTap: true,
                              ),
                            ),
                          )
                        : IsmChatProperties.chatPageProperties.placeholder ??
                            const IsmChatEmptyView(
                              icon: Icon(
                                Icons.chat_outlined,
                              ),
                              text: IsmChatStrings.noMessages,
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
      );
}
