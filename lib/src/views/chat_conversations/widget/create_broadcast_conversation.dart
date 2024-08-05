import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatCreateBroadCastView extends StatelessWidget {
  const IsmChatCreateBroadCastView({
    super.key,
  });

  static const String route = IsmPageRoutes.createBroadcastView;

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        initState: (_) {
          final converstaionController =
              Get.find<IsmChatConversationsController>();
          converstaionController.callApiOrNot = true;
          converstaionController.forwardedList.clear();
          converstaionController.selectedUserList.clear();
          converstaionController.showSearchField = false;
          converstaionController.isLoadResponse = false;
          converstaionController.getNonBlockUserList(
            isGroupConversation: true,
            opponentId: converstaionController.userDetails?.userId,
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
                      controller.debounce.run(() {
                        controller.isLoadResponse = false;
                        controller.getNonBlockUserList(
                          searchTag: value,
                          opponentId: IsmChatConfig
                              .communicationConfig.userConfig.userId,
                        );
                      });
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
                      }
                    },
                  )
                : Text(
                    'Broadcast message to...  ${controller.selectedUserList.isEmpty ? '' : controller.selectedUserList.length}',
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
                  color:
                      IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                          IsmChatColors.whiteColor,
                ),
              )
            ],
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (controller.selectedUserList.isEmpty) ...[
                Container(
                  alignment: Alignment.center,
                  height: IsmChatDimens.ninty,
                  child: Text(
                    IsmChatStrings.contactAppear,
                    style: IsmChatStyles.w400Black14,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ] else ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                  height: IsmChatDimens.ninty,
                  child: ListView.separated(
                    padding: IsmChatDimens.edgeInsets10,
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.selectedUserList.length,
                    separatorBuilder: (_, __) => IsmChatDimens.boxWidth8,
                    itemBuilder: (context, index) {
                      var user = controller.selectedUserList[index];
                      return InkWell(
                        onTap: () {
                          controller.isSelectedUser(user);
                          controller.onForwardUserTap(
                            controller.forwardedList.indexOf(
                              controller.forwardedList.selectedUsers[index],
                            ),
                          );
                        },
                        child: SizedBox(
                          width: IsmChatDimens.fifty,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(
                                    width: IsmChatDimens.forty,
                                    height: IsmChatDimens.forty,
                                    child: IsmChatImage.profile(
                                      user.userProfileImageUrl,
                                      name: user.userName,
                                    ),
                                  ),
                                  Positioned(
                                    top: IsmChatDimens.twentySeven,
                                    left: IsmChatDimens.twentySeven,
                                    child: CircleAvatar(
                                      backgroundColor: IsmChatConfig
                                          .chatTheme.backgroundColor,
                                      radius: IsmChatDimens.eight,
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: IsmChatConfig
                                            .chatTheme.primaryColor,
                                        size: IsmChatDimens.twelve,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: IsmChatDimens.twentyEight,
                                child: Text(
                                  user.userName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: IsmChatStyles.w600Black10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              controller.forwardedList.isEmpty
                  ? Expanded(
                      child: Center(
                        child: controller.isLoadResponse
                            ? Text(
                                IsmChatStrings.noUserFound,
                                style: IsmChatStyles.w600Black16,
                              )
                            : const IsmChatLoadingDialog(),
                      ),
                    )
                  : Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            if (scrollNotification.metrics.pixels >
                                scrollNotification.metrics.maxScrollExtent *
                                    0.7) {
                              if ((scrollNotification.dragDetails?.velocity
                                          .pixelsPerSecond.dy ??
                                      0) <
                                  0) {
                                controller.getNonBlockUserList(
                                    opponentId: IsmChatConfig
                                        .communicationConfig.userConfig.userId);
                              }
                            }
                          }
                          return true;
                        },
                        child: controller.isLoadResponse &&
                                controller.forwardedList.isEmpty
                            ? Center(
                                child: Text(
                                  IsmChatStrings.noUserFound,
                                  style: IsmChatStyles.w600Black16,
                                ),
                              )
                            : AzListView(
                                padding: IsmChatDimens.edgeInsets0_10,
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
                                indexBarData: const []
                                // SuspensionUtil.getTagIndexList(
                                //     controller.forwardedList)

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
                                    children: [
                                      Offstage(
                                          offstage:
                                              user.isShowSuspension != true,
                                          child: _GetSuspensionTag(
                                              susTag: susTag)),
                                      ColoredBox(
                                        color: user.isUserSelected
                                            ? IsmChatConfig
                                                .chatTheme.primaryColor!
                                                .withOpacity(.2)
                                            : Colors.transparent,
                                        child: ListTile(
                                          onTap: () {
                                            controller.onForwardUserTap(index);
                                            controller.isSelectedUser(
                                                user.userDetails);
                                          },
                                          dense: true,
                                          mouseCursor: SystemMouseCursors.click,
                                          // tileColor: user.isUserSelected
                                          //     ? IsmChatConfig
                                          //         .chatTheme.primaryColor!
                                          //         .withOpacity(.2)
                                          //     : null,
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
                                            IsmChatProperties
                                                    .conversationProperties
                                                    .opponentSubTitle
                                                    ?.call(context,
                                                        user.userDetails) ??
                                                user.userDetails.userIdentifier,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: IsmChatStyles.w400Black12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
            ],
          ),
          floatingActionButton: IsmChatStartChatFAB(
            onTap: () async {
              if (controller.selectedUserList.isNotEmpty &&
                  controller.selectedUserList.length >= 2) {
                controller.goToBroadcastMessage(
                    controller.selectedUserList, '');
              } else {
                await Get.dialog(
                  const IsmChatAlertDialogBox(
                    title: IsmChatStrings.broadcastAlert,
                    cancelLabel: 'Okay',
                  ),
                );
              }
            },
            icon: Icon(
              Icons.done_rounded,
              size: IsmChatDimens.thirty,
              color: IsmChatColors.whiteColor,
            ),
          ),
        ),
      );
}

class _GetSuspensionTag extends StatelessWidget {
  const _GetSuspensionTag({
    required this.susTag,
  });

  final String susTag;

  @override
  Widget build(BuildContext context) => Container(
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
}
