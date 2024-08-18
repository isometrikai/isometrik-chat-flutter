import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatForwardView extends StatelessWidget {
  IsmChatForwardView({
    super.key,
    IsmChatMessageModel? message,
    IsmChatConversationModel? conversation,
  })  : _conversation = conversation ??
            (Get.arguments as Map<String, dynamic>?)?['conversation'],
        _message =
            message ?? (Get.arguments as Map<String, dynamic>?)?['message'];

  /// The selected [_message] which is to be forwarded
  final IsmChatMessageModel? _message;

  /// The [_conversation] to which the selected [_message] is to be forwarded
  final IsmChatConversationModel? _conversation;

  final converstaionController = Get.find<IsmChatConversationsController>();

  static const String route = IsmPageRoutes.forwardView;

  Widget _buildSusWidget(String susTag) => Container(
        padding: IsmChatDimens.edgeInsets10_0,
        height: IsmChatDimens.forty,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              susTag,
              textScaler: const TextScaler.linear(1.5),
              style: IsmChatStyles.w600Black14,
            ),
            SizedBox(
                width: IsmChatDimens.percentWidth(
                  IsmChatResponsive.isWeb(Get.context!) ? .23 : .7,
                ),
                child: Divider(
                  height: .0,
                  indent: IsmChatDimens.ten,
                ))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        initState: (_) {
          converstaionController.callApiOrNot = true;
          converstaionController.forwardedList.clear();
          converstaionController.selectedUserList.clear();

          converstaionController.showSearchField = false;
          converstaionController.isLoadResponse = false;
          converstaionController.getNonBlockUserList(
            opponentId: _conversation?.opponentDetails?.userId,
          );
        },
        builder: (controller) => Scaffold(
          backgroundColor: IsmChatColors.whiteColor,
          appBar: IsmChatAppBar(
            title: controller.showSearchField
                ? IsmChatInputField(
                    fillColor: IsmChatConfig.chatTheme.primaryColor,
                    style: IsmChatStyles.w400White16,
                    hint: IsmChatStrings.searchUser,
                    hintStyle: IsmChatStyles.w400White16,
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        controller.forwardedList =
                            controller.forwardedListDuplicat
                                .map((e) => SelectedMembers(
                                      isUserSelected:
                                          controller.selectedUserList.any((d) =>
                                              d.userId == e.userDetails.userId),
                                      userDetails: e.userDetails,
                                      isBlocked: e.isBlocked,
                                      tagIndex: e.tagIndex,
                                    ))
                                .toList();
                        controller.handleList(controller.forwardedList);
                        return;
                      }
                      controller.debounce.run(() {
                        controller.isLoadResponse = false;
                        controller.getNonBlockUserList(
                          searchTag: value,
                          opponentId: IsmChatConfig
                              .communicationConfig.userConfig.userId,
                        );
                      });
                    },
                  )
                : Text(
                    'Forward to...  ${controller.selectedUserList.isEmpty ? '' : controller.selectedUserList.length}',
                    style: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
                  ),
            action: [
              IconButton(
                onPressed: () {
                  controller.showSearchField = !controller.showSearchField;

                  if (!controller.showSearchField &&
                      controller.forwardedListDuplicat.isNotEmpty) {
                    controller.forwardedList = controller.forwardedListDuplicat
                        .map(
                          (e) => SelectedMembers(
                              isUserSelected: controller.selectedUserList
                                  .any((d) => d.userId == e.userDetails.userId),
                              userDetails: e.userDetails,
                              isBlocked: e.isBlocked,
                              tagIndex: e.tagIndex),
                        )
                        .toList();
                    controller.handleList(controller.forwardedList);
                  }
                  if (controller.isLoadResponse) {
                    controller.isLoadResponse = false;
                  }
                },
                icon: Icon(
                  controller.showSearchField
                      ? Icons.clear_rounded
                      : Icons.search_rounded,
                  color: IsmChatColors.whiteColor,
                ),
              )
            ],
          ),
          body: controller.forwardedList.isEmpty
              ? controller.isLoadResponse
                  ? Center(
                      child: Text(
                        IsmChatStrings.noUserFound,
                        style: IsmChatStyles.w600Black16,
                      ),
                    )
                  : const IsmChatLoadingDialog()
              : Column(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            if (scrollNotification.metrics.pixels >
                                scrollNotification.metrics.maxScrollExtent *
                                    0.7) {
                              controller.getNonBlockUserList(
                                  opponentId: IsmChatConfig
                                      .communicationConfig.userConfig.userId);
                            }
                          }
                          return true;
                        },
                        child: controller.isLoadResponse
                            ? Center(
                                child: Text(
                                  IsmChatStrings.noUserFound,
                                  style: IsmChatStyles.w600Black16,
                                ),
                              )
                            : AzListView(
                                data: controller.forwardedList,
                                itemCount: controller.forwardedList.length,
                                indexHintBuilder: (context, hint) => Container(
                                  alignment: Alignment.center,
                                  width: IsmChatDimens.eighty,
                                  height: IsmChatDimens.eighty,
                                  decoration: BoxDecoration(
                                    color: IsmChatConfig.chatTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(hint,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: IsmChatDimens.thirty)),
                                ),
                                indexBarMargin: IsmChatDimens.edgeInsets10,
                                indexBarData: SuspensionUtil.getTagIndexList(
                                    controller.forwardedList)
                                // [
                                //     'A',
                                //     'B',
                                //     'C',
                                //     'D',
                                //     'E',
                                //     'F',
                                //     'G',
                                //     'H',
                                //     'I',
                                //     'J',
                                //     'K',
                                //     'L',
                                //     'M',
                                //     'N',
                                //     'O',
                                //     'P',
                                //     'Q',
                                //     'R',
                                //     'S',
                                //     'T',
                                //     'U',
                                //     'V',
                                //     'W',
                                //     'X',
                                //     'Y',
                                //     'Z'
                                //   ],
                                ,
                                indexBarHeight: IsmChatDimens.percentHeight(5),
                                indexBarWidth: IsmChatDimens.forty,
                                indexBarItemHeight: IsmChatDimens.twenty,
                                indexBarOptions: IndexBarOptions(
                                  indexHintDecoration: const BoxDecoration(
                                      color: IsmChatColors.whiteColor),
                                  indexHintChildAlignment: Alignment.center,
                                  selectTextStyle: IsmChatStyles.w400White12,
                                  selectItemDecoration: BoxDecoration(
                                    color: IsmChatConfig.chatTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  needRebuild: true,
                                  indexHintHeight:
                                      IsmChatDimens.percentHeight(.2),
                                ),
                                itemBuilder: (_, int index) {
                                  var user = controller.forwardedList[index];
                                  var susTag = user.getSuspensionTag();
                                  if (user.userDetails.userId ==
                                      IsmChatConfig.communicationConfig
                                          .userConfig.userId) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Offstage(
                                        offstage: user.isShowSuspension != true,
                                        child: _buildSusWidget(susTag),
                                      ),
                                      ColoredBox(
                                        color: user.isUserSelected
                                            ? IsmChatConfig
                                                .chatTheme.primaryColor!
                                                .withOpacity(.2)
                                            : Colors.transparent,
                                        child: ListTile(
                                          onTap: !user.isUserSelected &&
                                                  controller
                                                          .forwardedList
                                                          .selectedUsers
                                                          .length >
                                                      4
                                              ? () {
                                                  Get.dialog(
                                                    AlertDialog(
                                                      title: const Text(
                                                          'Alert message...'),
                                                      content: const Text(
                                                          'You can only share with up to 5 chats'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: Get.back,
                                                          child: const Text(
                                                            'Okay',
                                                            style: TextStyle(
                                                                fontSize: 15),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }
                                              : () async {
                                                  controller
                                                      .onForwardUserTap(index);

                                                  controller.isSelectedUser(
                                                      user.userDetails);
                                                },
                                          dense: true,
                                          mouseCursor: SystemMouseCursors.click,
                                          leading: IsmChatImage.profile(
                                            user.userDetails
                                                .userProfileImageUrl,
                                            name: user.userDetails.userName,
                                          ),
                                          title: Text(
                                            user.userDetails.userName,
                                            style: IsmChatStyles.w600Black14,
                                          ),
                                          subtitle: Text(
                                            user.userDetails.userIdentifier,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: IsmChatStyles.w400Black12,
                                          ),
                                          autofocus: true,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                    if (controller.selectedUserList.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                        height: IsmChatDimens.sixty,
                        padding: IsmChatDimens.edgeInsets10_0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: IsmChatDimens.edgeInsets10,
                                child: Text(
                                  controller.selectedUserList
                                      .map((e) => e.userName)
                                      .join(', '),
                                  maxLines: 1,
                                  style: IsmChatStyles.w600Black12,
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              thickness: 1,
                              color: IsmChatColors.greyColorLight,
                            ),
                            FloatingActionButton(
                              onPressed: () async {
                                if (IsmChatProperties
                                        .chatPageProperties.onForwardTap !=
                                    null) {
                                  IsmChatProperties
                                      .chatPageProperties.onForwardTap!
                                      .call(context,
                                          controller.currentConversation!);
                                }

                                if (await IsmChatProperties.chatPageProperties
                                        .messageAllowedConfig?.isMessgeAllowed
                                        ?.call(
                                            Get.context!,
                                            Get.find<IsmChatPageController>()
                                                .conversation!) ??
                                    true) {
                                  await controller.sendForwardMessage(
                                    customType:
                                        _message?.customType?.name ?? '',
                                    userIds: controller.selectedUserList
                                        .map((e) => e.userId)
                                        .toList(),
                                    body: _message?.body ?? '',
                                    metaData: _message?.metaData,
                                    attachments: _message?.attachments
                                        ?.map((e) => e.toMap())
                                        .toList(),
                                    isLoading: true,
                                  );
                                }
                              },
                              elevation: 0,
                              shape: const CircleBorder(),
                              backgroundColor:
                                  IsmChatConfig.chatTheme.primaryColor,
                              child: const Icon(
                                Icons.send_rounded,
                                color: IsmChatColors.whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      );
}
