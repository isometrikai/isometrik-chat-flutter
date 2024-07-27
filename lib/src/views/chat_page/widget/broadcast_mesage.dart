import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/src/controllers/controllers.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';
import 'package:isometrik_chat_flutter/src/utilities/utilities.dart';
import 'package:isometrik_chat_flutter/src/views/views.dart';
import 'package:isometrik_chat_flutter/src/widgets/widgets.dart';

class IsmChatBoradcastMessagePage extends StatelessWidget {
  const IsmChatBoradcastMessagePage({super.key});

  static const String route = IsmPageRoutes.boradCastMessagePage;

  Future<bool> _back(
    BuildContext context,
  ) async {
    var controller = Get.find<IsmChatPageController>();
    var conversationController = Get.find<IsmChatConversationsController>();

    if (Responsive.isWeb(context)) {
      var controller = Get.find<IsmChatPageController>();
      controller.isTemporaryChat = false;
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
                child: Icon(
                  Responsive.isWeb(context)
                      ? Icons.close_rounded
                      : Icons.arrow_back_rounded,
                  color:
                      IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                          IsmChatColors.whiteColor,
                ),
              ),
              centerTitle: controller.messages.isNotEmpty ? false : true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.conversation?.members?.length} Recipients Selected',
                    style: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White16,
                  ),
                  if (controller.messages.isNotEmpty)
                    Text(
                      (controller.conversation?.members ?? [])
                          .map((e) => e.userName)
                          .join(','),
                      style: IsmChatConfig
                              .chatTheme.chatPageHeaderTheme?.subtileStyle ??
                          IsmChatStyles.w400White12,
                    )
                ],
              ),
              backgroundColor: IsmChatConfig
                      .chatTheme.chatPageHeaderTheme?.backgroundColor ??
                  IsmChatConfig.chatTheme.primaryColor,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: controller.messages.isNotEmpty
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
                      : ListView.builder(
                          itemCount:
                              controller.conversation?.members?.length ?? 0,
                          itemBuilder: (_, index) {
                            var data = controller.conversation?.members?[index];
                            return Column(
                              children: [
                                ListTile(
                                  trailing: CircleAvatar(
                                    child: IconButton(
                                      onPressed: () {
                                        final conversationController = Get.find<
                                            IsmChatConversationsController>();
                                        conversationController
                                            .isSelectedUser(data!);
                                        conversationController.onForwardUserTap(
                                          conversationController.forwardedList
                                              .indexOf(
                                            conversationController.forwardedList
                                                .selectedUsers[index],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                                  ),
                                  leading: IsmChatImage.profile(
                                      data?.userProfileImageUrl ?? ''),
                                  title: Text(
                                    data?.userName ?? '',
                                  ),
                                  subtitle: Text(data?.userIdentifier ?? ''),
                                ),
                                const Divider()
                              ],
                            );
                          },
                        ),
                ),
                if (controller.messages.isEmpty && !Responsive.isWeb(context))
                  Container(
                    height: IsmChatDimens.forty,
                    width: IsmChatDimens.hundred,
                    decoration: BoxDecoration(
                      color: IsmChatConfig.chatTheme.primaryColor,
                      borderRadius: BorderRadius.circular(
                        IsmChatDimens.twenty,
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: Get.back,
                      icon: Icon(
                        Icons.add_rounded,
                        color: IsmChatColors.whiteColor,
                        size: IsmChatDimens.twenty,
                      ),
                      label: Text(
                        IsmChatStrings.add,
                        style: IsmChatStyles.w600White16,
                      ),
                    ),
                  ),
                IsmChatDimens.boxHeight20,
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
          ));
}
