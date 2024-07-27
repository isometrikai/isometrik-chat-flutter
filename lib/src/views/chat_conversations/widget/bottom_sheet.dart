import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatClearConversationBottomSheet extends StatelessWidget {
  const IsmChatClearConversationBottomSheet(this.conversation, {super.key});

  final IsmChatConversationModel conversation;

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
        builder: (controller) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Get.back();
                await Get.dialog(
                  IsmChatAlertDialogBox(
                    title: IsmChatStrings.deleteAllMessage,
                    actionLabels: const [IsmChatStrings.clearChat],
                    callbackActions: [
                      () => controller.clearAllMessages(
                            conversation.conversationId,
                            fromServer: conversation
                                            .lastMessageDetails?.customType ==
                                        IsmChatCustomMessageType.removeMember &&
                                    conversation.lastMessageDetails?.userId ==
                                        IsmChatConfig.communicationConfig
                                            .userConfig.userId
                                ? false
                                : true,
                          ),
                    ],
                  ),
                );
              },
              isDestructiveAction: true,
              child: Text(
                IsmChatStrings.clearChat,
                overflow: TextOverflow.ellipsis,
                style: IsmChatStyles.w600Black16,
              ),
            ),
            if (conversation.lastMessageDetails?.customType ==
                    IsmChatCustomMessageType.removeMember &&
                conversation.lastMessageDetails?.userId ==
                    IsmChatConfig.communicationConfig.userConfig.userId) ...[
              CupertinoActionSheetAction(
                onPressed: () async {
                  Get.back();
                  await Get.dialog(
                    IsmChatAlertDialogBox(
                      title: IsmChatStrings.deleteThiGroup,
                      actionLabels: const [IsmChatStrings.deleteGroup],
                      callbackActions: [
                        () => controller.deleteChat(
                              conversation.conversationId,
                              deleteFromServer: false,
                            ),
                      ],
                    ),
                  );
                },
                isDestructiveAction: true,
                child: Text(
                  IsmChatStrings.deleteGroup,
                  overflow: TextOverflow.ellipsis,
                  style: IsmChatStyles.w600Black16
                      .copyWith(color: IsmChatColors.redColor),
                ),
              ),
            ] else ...[
              CupertinoActionSheetAction(
                onPressed: () async {
                  Get.back();
                  if (conversation.isGroup == true) {
                    // await Get.dialog(
                    //   IsmChatAlertDialogBox(
                    //     title: 'Exit ${conversation.chatName}?',
                    //     content: const Text(
                    //       'Only group admins will be notified that you left the group',
                    //     ),
                    //     contentTextStyle: IsmChatStyles.w400Grey14,
                    //     actionLabels: const ['Exit'],
                    //     callbackActions: [
                    //       () {
                    //         //  _leaveGroup(
                    //         //     adminCount: adminCount,
                    //         //     isUserAdmin: isUserAdmin,
                    //         //   )
                    //       }
                    //     ],
                    //   ),
                    // );
                  } else {
                    await Get.dialog(
                      IsmChatAlertDialogBox(
                        title: '${IsmChatStrings.deleteChat}?',
                        actionLabels: const [IsmChatStrings.deleteChat],
                        callbackActions: [
                          () => controller
                              .deleteChat(conversation.conversationId),
                        ],
                      ),
                    );
                  }
                },
                isDestructiveAction: true,
                child: Text(
                  conversation.isGroup == true
                      ? IsmChatStrings.exitGroup
                      : IsmChatStrings.deleteChat,
                  overflow: TextOverflow.ellipsis,
                  style: IsmChatStyles.w600Black16
                      .copyWith(color: IsmChatColors.redColor),
                ),
              ),
            ],
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: Get.back,
            child: Text(
              IsmChatStrings.cancel,
              style: IsmChatStyles.w600Black16,
            ),
          ),
        ),
      );
}
