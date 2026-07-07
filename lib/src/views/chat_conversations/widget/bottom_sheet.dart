import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatClearConversationBottomSheet extends StatelessWidget {
  const IsmChatClearConversationBottomSheet(this.conversation, {super.key});

  final IsmChatConversationModel conversation;

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
        tag: IsmChat.i.chatListPageTag,
        builder: (controller) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                IsmChatRoute.goBack();
                await IsmChatConfirmationHelper.present(
                  IsmChatConfirmationRequest(
                    type: IsmChatConfirmationType.clearChatMessages,
                    title: IsmChatStrings.clearAllMessages,
                    conversation: conversation,
                    actions: [
                      IsmChatConfirmationAction(
                        id: IsmChatConfirmationActionId.clearChat,
                        label: IsmChatStrings.clearChat,
                        onPressed: () => controller.clearAllMessages(
                          conversation.conversationId,
                          fromServer:
                              IsmChatConfirmationHelper
                                  .shouldClearMessagesFromServer(conversation),
                        ),
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
                  IsmChatRoute.goBack();
                  await IsmChatConfirmationHelper.present(
                    IsmChatConfirmationRequest(
                      type: IsmChatConfirmationType.deleteGroup,
                      title: IsmChatStrings.deleteThiGroup,
                      conversation: conversation,
                      actions: [
                        IsmChatConfirmationAction(
                          id: IsmChatConfirmationActionId.deleteGroup,
                          label: IsmChatStrings.deleteGroup,
                          onPressed: () => controller.deleteChat(
                            conversation.conversationId,
                            deleteFromServer: false,
                          ),
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
                  IsmChatRoute.goBack();
                  if (conversation.isGroup == true) {
                    await controller.showExitGroupDialog(conversation);
                  } else {
                    await IsmChatConfirmationHelper.present(
                      IsmChatConfirmationRequest(
                        type: IsmChatConfirmationType.deleteChat,
                        title: '${IsmChatStrings.deleteChat}?',
                        conversation: conversation,
                        actions: [
                          IsmChatConfirmationAction(
                            id: IsmChatConfirmationActionId.deleteChat,
                            label: IsmChatStrings.deleteChat,
                            onPressed: () => controller.deleteChat(
                              conversation.conversationId,
                            ),
                          ),
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
            onPressed: IsmChatRoute.goBack,
            child: Text(
              IsmChatStrings.cancel,
              style: IsmChatStyles.w600Black16,
            ),
          ),
        ),
      );
}
