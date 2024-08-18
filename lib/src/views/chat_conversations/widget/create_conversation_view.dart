import 'dart:async';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatCreateConversationView extends StatelessWidget {
  IsmChatCreateConversationView(
      {super.key,
      bool? isGroupConversation,
      IsmChatConversationType? conversationType})
      : _isGroupConversation = isGroupConversation ??
            (Get.arguments as Map<String, dynamic>?)?['isGroupConversation'] ??
            false,
        _conversationType = conversationType ??
            (Get.arguments as Map<String, dynamic>?)?['conversationType'] ??
            IsmChatConversationType.private;

  final bool? _isGroupConversation;
  final IsmChatConversationType? _conversationType;
  final converstaionController = Get.find<IsmChatConversationsController>();

  static const String route = IsmPageRoutes.createChat;

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        initState: (_) async {
          converstaionController
              .initCreateConversation(_isGroupConversation ?? false);
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: IsmChatAppBar(
            title: controller.showSearchField
                ? IsmChatInputField(
                    fillColor: IsmChatConfig.chatTheme.primaryColor,
                    controller: controller.userSearchNameController,
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
                      controller.debounce.run(() async {
                        controller.isLoadResponse = false;
                        await controller.getNonBlockUserList(
                          searchTag: value,
                          opponentId: IsmChatConfig
                              .communicationConfig.userConfig.userId,
                        );
                        if (_isGroupConversation == false) {
                          controller.searchOnLocalContacts(value);
                        }
                      });
                    },
                  )
                : Text(
                    _isGroupConversation ?? false
                        ? '${IsmChatStrings.newString}  ${_conversationType == IsmChatConversationType.public ? 'Public' : _conversationType == IsmChatConversationType.open ? 'Open' : 'Group'} Conversation'
                        : IsmChatStrings.newConversation,
                    style: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
                  ),
            action: [
              IconButton(
                onPressed: () {
                  controller.showSearchField = !controller.showSearchField;
                  controller.userSearchNameController.clear();
                  if (!controller.showSearchField &&
                      controller.forwardedListDuplicat.isNotEmpty) {
                    controller.forwardedList = controller.forwardedListDuplicat
                        .map((e) => SelectedMembers(
                            isUserSelected: controller.selectedUserList
                                .any((d) => d.userId == e.userDetails.userId),
                            userDetails: e.userDetails,
                            isBlocked: e.isBlocked,
                            tagIndex: e.tagIndex))
                        .toList();
                    controller.handleList(controller.forwardedList);
                    controller.addContact(isLoading: false);
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
                    if (_isGroupConversation ?? false) ...[
                      Container(
                          width: Get.width,
                          color: IsmChatColors.whiteColor,
                          child: const _GroupChatImageAndName()),
                    ],
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (controller
                              .userSearchNameController.text.isEmpty) {
                            if (scrollNotification is ScrollEndNotification) {
                              if (scrollNotification.metrics.pixels >
                                  scrollNotification.metrics.maxScrollExtent *
                                      0.3) {
                                /// call the api only on down scroll
                                unawaited(controller.getNonBlockUserList(
                                  isGroupConversation:
                                      _isGroupConversation ?? false,
                                  opponentId: IsmChatConfig
                                      .communicationConfig.userConfig.userId,
                                ));
                              }
                            }
                          }

                          return true;
                        },
                        child: AzListView(
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
                            child: Text(
                              hint,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                          indexBarData: _isGroupConversation ?? false
                              ? const []
                              : SuspensionUtil.getTagIndexList(
                                  controller.forwardedList),
                          indexBarMargin: IsmChatDimens.edgeInsets10,
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
                            indexHintHeight: IsmChatDimens.percentHeight(.2),
                          ),
                          itemBuilder: (_, int index) {
                            var user = controller.forwardedList[index];
                            var susTag = user.getSuspensionTag();
                            if (user.userDetails.userId ==
                                IsmChatConfig
                                    .communicationConfig.userConfig.userId) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                if (index == 0 &&
                                    !_isGroupConversation! &&
                                    IsmChatConfig.communicationConfig.userConfig
                                            .accessToken !=
                                        null)
                                  const ChatModes(),
                                Offstage(
                                  offstage: user.isShowSuspension != true,
                                  child: IsmChatUtility.buildSusWidget(susTag),
                                ),
                                ColoredBox(
                                  color: user.isUserSelected
                                      ? IsmChatConfig.chatTheme.primaryColor!
                                          .withOpacity(.2)
                                      : Colors.transparent,
                                  child: ListTile(
                                    onTap: () async {
                                      if (_isGroupConversation) {
                                        controller.onForwardUserTap(index);
                                        controller
                                            .isSelectedUser(user.userDetails);
                                      } else {
                                        if (controller.forwardedList[index]
                                                .localContacts ==
                                            true) {
                                          IsmChatUtility.toSMS(controller
                                              .forwardedList[index]
                                              .userDetails
                                              .userIdentifier);
                                          return;
                                        }
                                        var ismChatConversation =
                                            IsmChatConversationModel(
                                                messagingDisabled: false,
                                                conversationImageUrl: user
                                                    .userDetails
                                                    .userProfileImageUrl,
                                                isGroup: false,
                                                opponentDetails:
                                                    user.userDetails,
                                                unreadMessagesCount: 0,
                                                lastMessageDetails:
                                                    LastMessageDetails(
                                                  sentByMe: true,
                                                  showInConversation: true,
                                                  sentAt: DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                  senderName: '',
                                                  messageType: 0,
                                                  messageId: '',
                                                  conversationId: '',
                                                  body: '',
                                                ),
                                                lastMessageSentAt: 0,
                                                membersCount: 1,
                                                conversationType:
                                                    _conversationType);
                                        ismChatConversation =
                                            ismChatConversation.copyWith(
                                          conversationId:
                                              controller.getConversationId(
                                            user.userDetails.userId,
                                          ),
                                        );
                                        Get.back<void>();
                                        IsmChatProperties
                                            .conversationProperties.onChatTap
                                            ?.call(_, ismChatConversation);
                                        controller.navigateToMessages(
                                            ismChatConversation);
                                        await controller.goToChatPage();
                                      }
                                    },
                                    dense: true,
                                    mouseCursor: SystemMouseCursors.click,
                                    leading: IsmChatImage.profile(
                                      user.userDetails.userProfileImageUrl,
                                      name: user.userDetails.userName,
                                    ),
                                    title: Text(
                                      user.userDetails.userName,
                                      style: IsmChatStyles.w600Black14,
                                    ),
                                    subtitle: Text(
                                      IsmChatProperties.conversationProperties
                                              .opponentSubTitle
                                              ?.call(
                                                  context, user.userDetails) ??
                                          user.userDetails.userIdentifier,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: IsmChatStyles.w400Black12,
                                    ),
                                    trailing: !_isGroupConversation!
                                        ? null
                                        : Container(
                                            padding:
                                                IsmChatDimens.edgeInsets8_4,
                                            decoration: BoxDecoration(
                                              color: IsmChatConfig
                                                  .chatTheme.primaryColor
                                                  ?.withOpacity(.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      IsmChatDimens.eight),
                                            ),
                                            child: Text(
                                              user.isUserSelected
                                                  ? 'Remove'
                                                  : 'Add',
                                              style: IsmChatStyles.w400Black12
                                                  .copyWith(
                                                color: IsmChatConfig
                                                    .chatTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    if (controller.selectedUserList.isNotEmpty &&
                        _isGroupConversation!)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                        height: IsmChatDimens.eighty,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.selectedUserList.length,
                                separatorBuilder: (_, __) =>
                                    IsmChatDimens.boxWidth8,
                                itemBuilder: (context, index) {
                                  var user = controller.selectedUserList[index];
                                  return InkWell(
                                    onTap: () {
                                      controller.isSelectedUser(user);
                                      controller.onForwardUserTap(
                                        controller.forwardedList.indexOf(
                                          controller.forwardedList
                                              .selectedUsers[index],
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: IsmChatDimens.fifty,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                      .chatTheme
                                                      .backgroundColor,
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
                            IsmChatDimens.boxWidth8,
                            FloatingActionButton(
                              elevation: 0,
                              shape: const CircleBorder(),
                              backgroundColor:
                                  IsmChatConfig.chatTheme.primaryColor,
                              child: const Icon(
                                Icons.send_rounded,
                                color: IsmChatColors.whiteColor,
                              ),
                              onPressed: () async {
                                if (controller.profileImage.isEmpty) {
                                  controller.profileImage =
                                      'https://admin-media1.isometrik.io/profile/def_group_profile.png';
                                }
                                if ((controller.forwardedList.selectedUsers
                                            .isEmpty &&
                                        controller.selectedUserList.isEmpty) ||
                                    controller.profileImage.isEmpty ||
                                    controller
                                        .addGrouNameController.text.isEmpty) {
                                  await Get.dialog(
                                    const IsmChatAlertDialogBox(
                                      cancelLabel: IsmChatStrings.okay,
                                      title: IsmChatStrings.createGroupAlert,
                                    ),
                                  );
                                  return;
                                }

                                var userIds = <String>[];
                                for (var x in controller.selectedUserList) {
                                  userIds.add(x.userId);
                                }

                                var conversation = IsmChatConversationModel(
                                  messagingDisabled: false,
                                  userIds: userIds,
                                  conversationTitle:
                                      controller.addGrouNameController.text,
                                  conversationImageUrl: controller.profileImage,
                                  isGroup: true,
                                  opponentDetails: controller.userDetails,
                                  unreadMessagesCount: 0,
                                  createdAt:
                                      DateTime.now().millisecondsSinceEpoch,
                                  createdByUserName: IsmChatConfig
                                          .communicationConfig
                                          .userConfig
                                          .userName ??
                                      controller.userDetails?.userName ??
                                      '',
                                  lastMessageDetails: LastMessageDetails(
                                    sentByMe: true,
                                    showInConversation: true,
                                    sentAt:
                                        DateTime.now().millisecondsSinceEpoch,
                                    senderName: '',
                                    messageType: 0,
                                    messageId: '',
                                    conversationId: '',
                                    body: '',
                                  ),
                                  lastMessageSentAt: 0,
                                  conversationType: _conversationType,
                                  membersCount:
                                      controller.selectedUserList.length + 1,
                                );

                                Get.back<void>();
                                IsmChatProperties
                                    .conversationProperties.onChatTap!
                                    .call(context, conversation);
                                controller.navigateToMessages(conversation);
                                await controller.goToChatPage();
                              },
                            ),
                            IsmChatDimens.boxWidth8,
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      );
}

class _GroupChatImageAndName extends StatelessWidget {
  const _GroupChatImageAndName();

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        builder: (controller) => Column(
          children: [
            IsmChatDimens.boxHeight10,
            Stack(
              children: [
                if (controller.profileImage.isEmpty)
                  Container(
                    width: IsmChatDimens.hundred,
                    height: IsmChatDimens.hundred,
                    decoration: BoxDecoration(
                      color: IsmChatConfig.chatTheme.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: IsmChatDimens.sixty,
                      color: IsmChatConfig.chatTheme.primaryColor,
                    ),
                  )
                else
                  IsmChatTapHandler(
                    onTap: () {
                      if (kIsWeb) {
                        controller.ismUploadImage(ImageSource.gallery);
                      } else {
                        Get.back();
                        Get.bottomSheet<void>(
                          IsmChatProfilePhotoBottomSheet(
                            onCameraTap: () async {
                              Get.back();
                              await controller
                                  .ismUploadImage(ImageSource.camera);
                            },
                            onGalleryTap: () async {
                              Get.back();
                              await controller
                                  .ismUploadImage(ImageSource.gallery);
                            },
                          ),
                          elevation: 0,
                        );
                      }
                    },
                    child: IsmChatImage.profile(
                      controller.profileImage,
                      dimensions: IsmChatDimens.hundred,
                    ),
                  ),
                Positioned(
                  bottom: IsmChatDimens.four,
                  right: IsmChatDimens.four,
                  child: IsmChatTapHandler(
                    onTap: () {
                      if (IsmChatResponsive.isWeb(context)) {
                        controller.ismUploadImage(ImageSource.gallery);
                      } else {
                        Get.bottomSheet<void>(
                          IsmChatProfilePhotoBottomSheet(
                            onCameraTap: () async {
                              Get.back();
                              await controller
                                  .ismUploadImage(ImageSource.camera);
                            },
                            onGalleryTap: () async {
                              Get.back();
                              await controller
                                  .ismUploadImage(ImageSource.gallery);
                            },
                          ),
                          elevation: 0,
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: IsmChatConfig.chatTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: IsmChatDimens.edgeInsets6,
                      child: Icon(
                        Icons.edit_rounded,
                        color: IsmChatConfig.chatTheme.backgroundColor,
                        size: IsmChatDimens.sixteen,
                      ),
                    ),
                  ),
                )
              ],
            ),
            IsmChatDimens.boxHeight10,
            const GroupInputField(),
            IsmChatDimens.boxHeight4,
          ],
        ),
      );
}

class ChatModes extends StatelessWidget {
  const ChatModes({super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (IsmChatProperties.conversationProperties.enableGroupChat)
            ListTile(
              onTap: () async {
                Get.back();
                await Future.delayed(Durations.extralong1);
                IsmChatRouteManagement.goToCreateChat(
                  isGroupConversation: true,
                  conversationType: IsmChatConversationType.private,
                );
              },
              contentPadding: IsmChatDimens.edgeInsets10,
              horizontalTitleGap: IsmChatDimens.ten,
              title: Text(
                IsmChatStrings.newGroup,
                style: IsmChatStyles.w600Black14,
              ),
              dense: true,
              mouseCursor: SystemMouseCursors.click,
              leading: Container(
                alignment: Alignment.center,
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFF3F3F9)),
                child: const Icon(Icons.group),
              ),
            ),
          // ListTile(
          //   contentPadding: IsmChatDimens.edgeInsets10,
          //   horizontalTitleGap: IsmChatDimens.ten,
          //   title: Text(
          //     IsmChatStrings.newContact,
          //     style: IsmChatStyles.w600Black14,
          //   ),
          //   dense: true,
          //   mouseCursor: SystemMouseCursors.click,
          //   leading: Container(
          //     alignment: Alignment.center,
          //     height: 60,
          //     width: 60,
          //     decoration: const BoxDecoration(
          //         shape: BoxShape.circle, color: Color(0xFFF3F3F9)),
          //     child: const Icon(Icons.person_add),
          //   ),
          // ),
          // ListTile(
          //   contentPadding: IsmChatDimens.edgeInsets10,
          //   horizontalTitleGap: IsmChatDimens.ten,
          //   title: Text(
          //     IsmChatStrings.newCommunity,
          //     style: IsmChatStyles.w600Black14,
          //   ),
          //   dense: true,
          //   mouseCursor: SystemMouseCursors.click,
          //   leading: Container(
          //     alignment: Alignment.center,
          //     height: 60,
          //     width: 60,
          //     decoration: const BoxDecoration(
          //         shape: BoxShape.circle, color: Color(0xFFF3F3F9)),
          //     child: const Icon(Icons.groups_2),
          //   ),
          // ),
          ListTile(
            onTap: () async {
              Get.back();
              await Future.delayed(Durations.extralong1);
              IsmChatRouteManagement.goToCreteBroadcastView();
            },
            contentPadding: IsmChatDimens.edgeInsets10,
            horizontalTitleGap: IsmChatDimens.ten,
            title: Text(
              IsmChatStrings.boradcastMessge,
              style: IsmChatStyles.w600Black14,
            ),
            dense: true,
            mouseCursor: SystemMouseCursors.click,
            leading: Container(
              alignment: Alignment.center,
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(
                  0xFFF3F3F9,
                ),
              ),
              child: const Icon(Icons.campaign),
            ),
          )
        ],
      );
}
