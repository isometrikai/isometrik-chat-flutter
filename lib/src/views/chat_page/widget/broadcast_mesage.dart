import 'dart:async';

import 'package:custom_will_pop_scope/custom_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatBoradcastMessagePage extends StatefulWidget {
  const IsmChatBoradcastMessagePage({super.key, this.viewTag});

  final String? viewTag;

  @override
  State<IsmChatBoradcastMessagePage> createState() =>
      _IsmChatBoradcastMessagePageState();
}

class _IsmChatBoradcastMessagePageState
    extends State<IsmChatBoradcastMessagePage> {
  @override
  void initState() {
    super.initState();
    IsmChat.i.chatPageTag = widget.viewTag;
    if (!IsmChatUtility.chatPageControllerRegistered) {
      IsmChatPageBinding().dependencies();
    }
  }

  @override
  void dispose() {
    IsmChat.i.chatPageTag = null;
    super.dispose();
  }

  Future<bool> _back(
    BuildContext context,
  ) async {
    var controller = IsmChatUtility.chatPageController;
    var conversationController = IsmChatUtility.conversationController;

    if (IsmChatResponsive.isWeb(context)) {
      var controller = IsmChatUtility.chatPageController;
      controller.isBroadcast = false;
      conversationController.currentConversation = null;
      conversationController.currentConversationId = '';
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.none;
      await Get.delete<IsmChatPageController>(
          force: true, tag: IsmChat.i.chatPageTag);
    } else {
      if (controller.messages.isNotEmpty) {
        IsmChatRoute.goBack();
      }
      IsmChatRoute.goBack();
    }
    if (controller.messages.isNotEmpty) {
      unawaited(conversationController.getChatConversations());
      conversationController.selectedUserList.clear();
      conversationController.forwardedList.clear();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => CustomWillPopScope(
        onWillPop: () async {
          if (!GetPlatform.isAndroid) return false;
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
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => Scaffold(
          backgroundColor:
              IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                  IsmChatColors.whiteColor,
          appBar: IsmChatAppBar(
            height: IsmChatDimens.fiftyFive,
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
      );
}
