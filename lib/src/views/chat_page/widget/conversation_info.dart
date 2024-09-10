import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConverstaionInfoView extends StatelessWidget {
  IsmChatConverstaionInfoView({super.key});

  static const String route = IsmPageRoutes.converstaionInfoView;

  final conversationController = Get.find<IsmChatConversationsController>();

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.tag,
        initState: (_) async {
          conversationController.mediaList.clear();
          conversationController.mediaListLinks.clear();
          conversationController.mediaListDocs.clear();
          var controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
          await controller.getConverstaionDetails(
            conversationId: controller.conversation?.conversationId ?? '',
            includeMembers:
                controller.conversation?.isGroup == true ? true : false,
            isLoading: false,
          );
        },
        builder: (controller) => Scaffold(
          backgroundColor: IsmChatColors.blueGreyColor,
          appBar: IsmChatAppBar(
            onBack: !IsmChatResponsive.isWeb(context)
                ? null
                : () {
                    Get.find<IsmChatConversationsController>()
                        .isRenderChatPageaScreen = IsRenderChatPageScreen.none;
                  },
            title: Text(
              controller.conversation?.isGroup ?? false
                  ? IsmChatStrings.groupInfo
                  : IsmChatStrings.contactInfo,
              style: IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                  IsmChatStyles.w600White18,
            ),
            action: [
              if (controller.conversation?.isGroup ?? false)
                Padding(
                  padding: EdgeInsets.only(
                      right: IsmChatDimens.five, top: IsmChatDimens.two),
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: IsmChatConfig
                              .chatTheme.chatPageHeaderTheme?.iconColor ??
                          IsmChatColors.whiteColor,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit,
                              color: IsmChatColors.blackColor,
                            ),
                            IsmChatDimens.boxWidth8,
                            const Text(IsmChatStrings.changeGroupTitle)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.photo,
                              color: IsmChatColors.blackColor,
                            ),
                            IsmChatDimens.boxWidth8,
                            const Text(IsmChatStrings.changeGroupPhoto)
                          ],
                        ),
                      ),
                    ],
                    elevation: 2,
                    onSelected: (value) {
                      if (value == 1) {
                        controller.showDialogForChangeGroupTitle();
                      } else {
                        controller.showDialogForChangeGroupProfile();
                      }
                    },
                  ),
                ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: IsmChatDimens.edgeInsets16_0_16_0,
                child: Column(
                  children: [
                    IsmChatDimens.boxHeight16,
                    IsmChatTapHandler(
                      onTap: controller.conversation?.isGroup ?? false
                          ? () {
                              controller.showDialogForChangeGroupProfile();
                            }
                          : null,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          IsmChatTapHandler(
                            onTap: () {
                              IsmChatRouteManagement.goToProfilePicView(
                                  controller.conversation!.opponentDetails!);
                            },
                            child: IsmChatImage.profile(
                              controller.conversation?.profileUrl ?? '',
                              dimensions: IsmChatDimens.hundred,
                            ),
                          ),
                          if (controller.conversation?.isGroup ?? false)
                            CircleAvatar(
                              radius: IsmChatDimens.forteen,
                              child: Icon(
                                Icons.edit_outlined,
                                size: IsmChatDimens.eighteen,
                              ),
                            )
                        ],
                      ),
                    ),
                    IsmChatDimens.boxHeight5,
                    IsmChatTapHandler(
                        onTap: controller.conversation?.isGroup ?? false
                            ? () {
                                controller.groupTitleController.text =
                                    controller.conversation!.chatName;
                                controller.showDialogForChangeGroupTitle();
                              }
                            : null,
                        child: Text(
                          controller.conversation?.chatName ?? '',
                          textAlign: TextAlign.center,
                          style: IsmChatStyles.w600Black27,
                        )),
                    if (!(controller.conversation?.isGroup ?? false)) ...[
                      Text(
                        controller.conversation?.opponentDetails
                                ?.userIdentifier ??
                            '',
                        style: IsmChatStyles.w500GreyLight17,
                      ),
                    ],
                    if (controller.conversation?.isGroup ?? false) ...[
                      Text(
                        '${controller.conversation?.membersCount} ${IsmChatStrings.participants}',
                        style: IsmChatStyles.w400Grey14,
                      ),
                    ],
                    IsmChatDimens.boxHeight10,
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.conversation?.isGroup ?? false) ...[
                          Padding(
                            padding: IsmChatDimens.edgeInsets10_5_10_10,
                            child: Text(
                                '${IsmChatStrings.createdOn} ${controller.conversation?.createdAt?.toLastMessageTimeString()} ${IsmChatStrings.by} ${controller.conversation?.createdByUserName}'),
                          ),
                        ],
                        if ((!(controller.conversation?.isGroup ?? false)) &&
                            IsmChatProperties
                                    .conversationProperties.opponentSubTitle !=
                                null) ...[
                          Container(
                            width: IsmChatDimens.percentWidth(1),
                            padding: IsmChatDimens.edgeInsets16_8_16_8,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(IsmChatDimens.sixteen),
                              color: IsmChatColors.whiteColor,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  IsmChatStrings.aboutMe,
                                  style: IsmChatStyles.w400Black16,
                                ),
                                IsmChatDimens.boxHeight5,
                                Text(
                                  IsmChatProperties.conversationProperties
                                          .opponentSubTitle
                                          ?.call(
                                              context,
                                              controller.conversation!
                                                  .opponentDetails!) ??
                                      '',
                                ),
                              ],
                            ),
                          ),
                          IsmChatDimens.boxHeight10,
                        ],
                        Container(
                          padding: IsmChatDimens.edgeInsets16_8_16_8,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(IsmChatDimens.sixteen),
                            color: IsmChatColors.whiteColor,
                          ),
                          child: IsmChatTapHandler(
                            onTap: () {
                              if (IsmChatResponsive.isWeb(context)) {
                                Get.find<IsmChatConversationsController>()
                                        .isRenderChatPageaScreen =
                                    IsRenderChatPageScreen.coversationMediaView;
                              } else {
                                IsmChatRouteManagement.goToMedia(
                                  mediaList: conversationController.mediaList,
                                  mediaListLinks:
                                      conversationController.mediaListLinks,
                                  mediaListDocs:
                                      conversationController.mediaListDocs,
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SvgPicture.asset(
                                  IsmChatAssets.gallarySvg,
                                ),
                                IsmChatDimens.boxWidth12,
                                Text(
                                  IsmChatStrings.mediaLinksAndDocs,
                                  style: IsmChatStyles.w500Black16,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      '${conversationController.mediaList.length + conversationController.mediaListLinks.length + conversationController.mediaListDocs.length}',
                                      style: IsmChatStyles.w500GreyLight17,
                                    ),
                                    IsmChatDimens.boxWidth4,
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: IsmChatColors.greyColorLight,
                                      size: IsmChatDimens.fifteen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (controller.conversation!.isGroup ?? false) ...[
                      IsmChatDimens.boxHeight10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: IsmChatDimens.edgeInsets10,
                            child: Text(
                              '${controller.conversation?.membersCount} ${IsmChatStrings.participants}',
                              style: IsmChatStyles.w500Black16,
                            ),
                          ),
                          if (controller
                                  .conversation!.usersOwnDetails?.isAdmin ??
                              false)
                            IconButton(
                              onPressed: () {
                                controller.participnatsEditingController
                                    .clear();
                                if (IsmChatResponsive.isWeb(context)) {
                                  Get.find<IsmChatConversationsController>()
                                          .isRenderChatPageaScreen =
                                      IsRenderChatPageScreen.groupEligibleView;
                                } else {
                                  IsmChatRouteManagement.goToEligibleUser();
                                }
                              },
                              icon: Icon(
                                Icons.group_add_outlined,
                                color: IsmChatConfig.chatTheme.primaryColor,
                              ),
                            )
                        ],
                      ),
                      IsmChatInputField(
                        autofocus: false,
                        hint: 'Search using name or email',
                        cursorColor: IsmChatConfig.chatTheme.primaryColor,
                        style: IsmChatStyles.w400Black16,
                        controller: controller.participnatsEditingController,
                        suffixIcon: controller
                                .participnatsEditingController.text.isNotEmpty
                            ? IsmChatTapHandler(
                                onTap: () {
                                  controller.participnatsEditingController
                                      .clear();
                                  controller.onGroupSearch('');
                                  controller.update();
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: IsmChatConfig.chatTheme.primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.search_rounded,
                                color: IsmChatConfig.chatTheme.primaryColor,
                              ),
                        onChanged: (_) {
                          controller.onGroupSearch(_);
                          controller.update();
                        },
                      ),
                      Obx(
                        () => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, index) =>
                              IsmChatDimens.boxWidth4,
                          itemCount: controller.groupMembers.length,
                          itemBuilder: (_, index) {
                            var member = controller.groupMembers[index];
                            return ListTile(
                              onTap: member.isAdmin
                                  ? (controller.conversation!.usersOwnDetails
                                                  ?.isAdmin ??
                                              false) &&
                                          controller.conversation!
                                                  .usersOwnDetails?.memberId !=
                                              member.userId
                                      ? () {
                                          Get.dialog(
                                            IsmChatGroupAdminDialog(
                                                user: member,
                                                isAdmin: true,
                                                groupName: controller
                                                        .conversation
                                                        ?.conversationTitle ??
                                                    ''),
                                          );
                                        }
                                      : IsmChatConfig.communicationConfig
                                                  .userConfig.userId ==
                                              member.userId
                                          ? null
                                          : () async {
                                              await controller.showUserDetails(
                                                member,
                                                fromMessagePage: false,
                                              );
                                            }
                                  : controller.conversation!.usersOwnDetails
                                              ?.isAdmin ??
                                          false
                                      ? () {
                                          Get.dialog(
                                            IsmChatGroupAdminDialog(
                                              user: member,
                                              groupName: controller.conversation
                                                      ?.conversationTitle ??
                                                  '',
                                            ),
                                          );
                                        }
                                      : IsmChatConfig.communicationConfig
                                                  .userConfig.userId ==
                                              member.userId
                                          ? null
                                          : () async {
                                              await controller.showUserDetails(
                                                member,
                                                fromMessagePage: false,
                                              );
                                            },
                              trailing: member.isAdmin
                                  ? Text(
                                      IsmChatStrings.admin,
                                      style: IsmChatStyles.w600Black12.copyWith(
                                          color: IsmChatConfig
                                              .chatTheme.primaryColor),
                                    )
                                  : controller.conversation!.usersOwnDetails
                                              ?.isAdmin ??
                                          false
                                      ? const Icon(
                                          Icons.more_vert,
                                          color: IsmChatColors.blackColor,
                                        )
                                      : null,
                              title: Text(IsmChatConfig.communicationConfig
                                          .userConfig.userId ==
                                      member.userId
                                  ? IsmChatStrings.you
                                  : member.userName),
                              subtitle: Text(IsmChatProperties
                                      .conversationProperties.opponentSubTitle
                                      ?.call(context, member) ??
                                  member.metaData?.aboutText?.title ??
                                  ''),
                              leading: IsmChatImage.profile(member.profileUrl),
                            );
                          },
                        ),
                      ),
                      IsmChatDimens.boxHeight20,
                      Container(
                        padding: IsmChatDimens.edgeInsets16,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(IsmChatDimens.sixteen),
                          color: IsmChatColors.whiteColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                controller
                                    .showDialogForClearChatAndDeleteGroup();
                              },
                              icon: const Icon(
                                Icons.clear_all_rounded,
                                color: IsmChatColors.blackColor,
                              ),
                              label: Text(
                                IsmChatStrings.clearChat,
                                style: IsmChatStyles.w600Black16,
                              ),
                            ),
                            IsmChatDimens.boxHeight10,
                            Divider(
                              thickness: 1,
                              color:
                                  IsmChatColors.greyColorLight.withOpacity(.3),
                            ),
                            IsmChatDimens.boxHeight5,
                            TextButton.icon(
                              onPressed: controller.showDialogExitButton,
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: IsmChatColors.redColor,
                              ),
                              label: Text(
                                IsmChatStrings.exitGroup,
                                style: IsmChatStyles.w600red16,
                              ),
                            ),
                            IsmChatDimens.boxHeight5,
                          ],
                        ),
                      ),
                      IsmChatDimens.boxHeight32,
                    ] else ...[
                      IsmChatDimens.boxHeight32,
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(IsmChatDimens.sixteen),
                          color: IsmChatColors.whiteColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await Get.dialog(
                                  IsmChatAlertDialogBox(
                                    title: IsmChatStrings.deleteAllMessage,
                                    actionLabels: const [
                                      IsmChatStrings.clearChat
                                    ],
                                    callbackActions: [
                                      () => controller.clearAllMessages(
                                          '${controller.conversation?.conversationId}'),
                                    ],
                                  ),
                                );
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.clear_all_outlined,
                                color: IsmChatColors.redColor,
                              ),
                              label: Text(
                                IsmChatStrings.clearChat,
                                style: IsmChatStyles.w600red16,
                              ),
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                              color:
                                  IsmChatColors.greyColorLight.withOpacity(.3),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await Get.dialog(
                                  IsmChatAlertDialogBox(
                                    title: '${IsmChatStrings.deleteChat}?',
                                    actionLabels: const [
                                      IsmChatStrings.deleteChat
                                    ],
                                    callbackActions: [
                                      () => Get.find<
                                              IsmChatConversationsController>()
                                          .deleteChat(
                                              '${controller.conversation?.conversationId}'),
                                    ],
                                  ),
                                );
                                Get.back();
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.delete_forever_outlined,
                                color: IsmChatColors.redColor,
                              ),
                              label: Text(
                                IsmChatStrings.deleteChat,
                                style: IsmChatStyles.w600red16,
                              ),
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                              color:
                                  IsmChatColors.greyColorLight.withOpacity(.3),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await controller.handleBlockUnblock(true);
                              },
                              icon: const Icon(
                                Icons.block_outlined,
                                color: IsmChatColors.redColor,
                              ),
                              label: Text(
                                '${controller.conversation?.isBlockedByMe == true ? IsmChatStrings.unblock : IsmChatStrings.block} ${controller.conversation?.chatName ?? ''}',
                                style: IsmChatStyles.w600red16,
                              ),
                            )
                          ],
                        ),
                      ),
                      IsmChatDimens.boxHeight10,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ).withUnfocusGestureDetctor(context),
      );
}
